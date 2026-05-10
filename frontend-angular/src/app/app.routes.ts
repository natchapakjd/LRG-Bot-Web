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
import { adminGuard, authGuard } from './guards/auth.guard';

export const routes: Routes = [
  // Protected routes - require login
  { path: '', component: DashboardComponent, canActivate: [authGuard] },
  { path: 'devices', component: DeviceManagerComponent, canActivate: [authGuard] },
  { path: 'daily-login', component: DailyLoginComponent, canActivate: [authGuard] },
  { path: 'settings', component: SettingsComponent, canActivate: [authGuard] },
  { path: 'workflow-builder', component: WorkflowBuilderComponent, canActivate: [authGuard] },
  { path: 'template-sets', component: TemplateSetManagerComponent, canActivate: [authGuard] },
  { path: 'mode-config', component: ModeConfigurationComponent, canActivate: [authGuard] },
  { path: 'master-data', component: MasterDataComponent, canActivate: [adminGuard] },
  
  // Authenticated maintenance routes
  { path: 'license', component: LicenseComponent, canActivate: [authGuard] },
  
  // Admin routes - requires login
  { path: 'admin/login', component: LoginComponent },
  { path: 'admin/license', component: AdminLicenseComponent, canActivate: [adminGuard] },
  
  { path: '**', redirectTo: '' }
];
