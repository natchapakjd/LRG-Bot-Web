import { Routes } from '@angular/router';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { DailyLoginComponent } from './components/daily-login/daily-login.component';
import { DeviceManagerComponent } from './components/device-manager/device-manager.component';
import { LicenseComponent } from './components/license/license.component';
import { AdminLicenseComponent } from './components/admin-license/admin-license.component';
import { LoginComponent } from './components/login/login.component';
import { SettingsComponent } from './components/settings/settings.component';
import { WorkflowBuilderComponent } from './components/workflow-builder/workflow-builder.component';
import { TemplateSetManagerComponent } from './components/template-set-manager/template-set-manager.component';
import { ModeConfigurationComponent } from './components/mode-configuration/mode-configuration.component';
import { MasterDataComponent } from './components/master-data/master-data.component';
import { adminGuard, licenseGuard } from './guards/auth.guard';

export const routes: Routes = [
  // Protected routes - require valid license
  { path: '', component: DashboardComponent, canActivate: [licenseGuard] },
  { path: 'devices', component: DeviceManagerComponent, canActivate: [licenseGuard] },
  { path: 'daily-login', component: DailyLoginComponent, canActivate: [licenseGuard] },
  { path: 'settings', component: SettingsComponent, canActivate: [licenseGuard] },
  { path: 'workflow-builder', component: WorkflowBuilderComponent, canActivate: [licenseGuard] },
  { path: 'template-sets', component: TemplateSetManagerComponent, canActivate: [licenseGuard] },
  { path: 'mode-config', component: ModeConfigurationComponent, canActivate: [licenseGuard] },
  { path: 'master-data', component: MasterDataComponent, canActivate: [adminGuard] },
  
  // Public routes - license activation
  { path: 'license', component: LicenseComponent },
  
  // Admin routes - requires login
  { path: 'admin/login', component: LoginComponent },
  { path: 'admin/license', component: AdminLicenseComponent, canActivate: [adminGuard] },
  
  { path: '**', redirectTo: '' }
];
