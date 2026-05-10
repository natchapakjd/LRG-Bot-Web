import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { LicenseService } from '../services/license.service';

/**
 * Guard that requires user to be logged in.
 */
export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return authService.checkAuth().then((isAuthenticated) => {
      if (isAuthenticated) {
        return true;
      }

      router.navigate(['/admin/login']);
      return false;
    });
  }

  router.navigate(['/admin/login']);
  return false;
};

/**
 * Guard that requires user to be an admin.
 */
export const adminGuard: CanActivateFn = async () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const isAuthenticated = await authService.checkAuth();
  if (!isAuthenticated) {
    router.navigate(['/admin/login']);
    return false;
  }

  if (!authService.isAdmin()) {
    router.navigate(['/']);
    return false;
  }

  return true;
};

/**
 * Legacy license guard retained for compatibility. Auth is now the primary gate.
 */
export const licenseGuard: CanActivateFn = async () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const isAuthenticated = await authService.checkAuth();
  if (!isAuthenticated) {
    router.navigate(['/admin/login']);
    return false;
  }

  if (authService.isLoggedIn()) {
    return true;
  }

  const licenseService = inject(LicenseService);
  return licenseService.checkLicense();
};
