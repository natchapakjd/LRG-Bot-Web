import { Component, OnInit, OnDestroy, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { FormsModule } from '@angular/forms';

interface MasterItem {
  id: number;
  code: string;
  display_name: string;
  description?: string | null;
  icon?: string | null;
  category?: string | null;
  is_active: boolean;
  sort_order: number;
}

type MasterTab = 'mode' | 'step-type' | 'role';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  template: `
    <div class="settings-page">
      <h2 class="page-title">⚙️ Settings</h2>
      
      <!-- Master Workflow Section -->
      <div class="card workflow-section">
        <div class="section-header">
          <h3>🔧 Master Workflow</h3>
          <span class="status-badge" [class.active]="masterWorkflow()">
            {{ masterWorkflow() ? '✅ Set' : '⚠️ Not Set' }}
          </span>
        </div>
        
        <p class="section-desc">
          กำหนด Master Workflow สำหรับใช้เป็น automation template หลัก
        </p>
        
        @if (masterWorkflow()) {
          <div class="master-info">
            <span class="master-icon">⭐</span>
            <span class="master-name">{{ masterWorkflow().name }}</span>
            <span class="master-steps">{{ masterWorkflow().steps?.length || 0 }} steps</span>
          </div>
        }
        
        <button class="btn btn-primary" (click)="goToWorkflowBuilder()">
          🔧 Open Workflow Builder
        </button>
      </div>

      <!-- Master CRUD Section -->
      <div class="card master-crud-section">
        <div class="section-header">
          <h3>🗂️ Master Data Management</h3>
          <span class="status-badge" [class.active]="masterItems().length > 0">
            {{ masterLoading() ? '⏳ Loading' : (masterItems().length + ' records') }}
          </span>
        </div>

        <p class="section-desc">
          จัดการ master data ทั้งหมดจากหน้า Settings: Mode, Step Type และ Role
        </p>

        <div class="master-tabs">
          @for (tab of masterTabs; track tab.id) {
            <button
              class="master-tab-btn"
              [class.active]="activeMasterTab() === tab.id"
              (click)="switchMasterTab(tab.id)"
            >
              {{ tab.icon }} {{ tab.label }}
            </button>
          }
        </div>

        <div class="master-toolbar">
          <button class="btn btn-primary" (click)="startCreateMaster()">＋ Add</button>
          <button class="btn btn-light" (click)="loadMasterData()">↻ Refresh</button>
        </div>

        @if (masterError()) {
          <p class="message error">{{ masterError() }}</p>
        }

        @if (masterLoading()) {
          <div class="master-loading">กำลังโหลดข้อมูล...</div>
        } @else if (masterItems().length === 0) {
          <div class="master-empty">ยังไม่มีข้อมูลในหมวดนี้</div>
        } @else {
          <div class="master-table-wrap">
            <table class="master-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Code</th>
                  <th>Name</th>
                  @if (activeMasterTab() === 'step-type') {
                    <th>Category</th>
                  }
                  <th>Sort</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                @for (item of masterItems(); track item.id) {
                  <tr [class.inactive]="!item.is_active">
                    <td>{{ item.id }}</td>
                    <td><code>{{ item.code }}</code></td>
                    <td>{{ item.display_name }}</td>
                    @if (activeMasterTab() === 'step-type') {
                      <td>
                        <span class="category-pill">{{ item.category || '-' }}</span>
                      </td>
                    }
                    <td>{{ item.sort_order }}</td>
                    <td>
                      <span class="status-pill" [class.active]="item.is_active">
                        {{ item.is_active ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td class="actions-cell">
                      <button class="action-btn" (click)="startEditMaster(item)">Edit</button>
                      <button class="action-btn" (click)="toggleMasterActive(item)">
                        {{ item.is_active ? 'Disable' : 'Enable' }}
                      </button>
                      <button class="action-btn danger" (click)="deleteMasterItem(item)">Delete</button>
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        }

        @if (isEditingMaster()) {
          <div class="master-editor">
            <h4>{{ editingMasterItem() ? 'Edit Item' : 'Create Item' }}</h4>

            @if (!editingMasterItem()) {
              <label class="editor-label">Code</label>
              <input class="editor-input" [(ngModel)]="masterForm.code" placeholder="e.g. daily-login" />
            }

            <label class="editor-label">Display Name</label>
            <input class="editor-input" [(ngModel)]="masterForm.display_name" placeholder="Display name" />

            <label class="editor-label">Description</label>
            <input class="editor-input" [(ngModel)]="masterForm.description" placeholder="Optional description" />

            <label class="editor-label">Icon</label>
            <input class="editor-input" [(ngModel)]="masterForm.icon" placeholder="Optional icon" />

            @if (activeMasterTab() === 'step-type') {
              <label class="editor-label">Category</label>
              <select class="editor-input" [(ngModel)]="masterForm.category">
                <option value="action">action</option>
                <option value="detection">detection</option>
                <option value="control">control</option>
                <option value="loop">loop</option>
              </select>
            }

            <label class="editor-label">Sort Order</label>
            <input class="editor-input" type="number" [(ngModel)]="masterForm.sort_order" />

            <label class="editor-checkbox">
              <input type="checkbox" [(ngModel)]="masterForm.is_active" />
              Active
            </label>

            <div class="editor-actions">
              <button class="btn btn-primary" [disabled]="isSavingMaster()" (click)="saveMasterItem()">
                {{ isSavingMaster() ? 'Saving...' : 'Save' }}
              </button>
              <button class="btn btn-light" [disabled]="isSavingMaster()" (click)="cancelMasterEdit()">Cancel</button>
            </div>
          </div>
        }
      </div>
      
      <!-- Remote Access Section -->
      <div class="card remote-section">
        <div class="section-header">
          <h3>🌐 Remote Access</h3>
          <span class="status-badge" [class.active]="isConnected()">
            {{ isConnected() ? '🟢 Active' : '⚫ Inactive' }}
          </span>
        </div>
        
        <p class="section-desc">
          เปิด Remote Access เพื่อดู Dashboard จากมือถือหรือคอมเครื่องอื่น
        </p>
        
        @if (!isConnected()) {
          <button 
            class="btn btn-primary" 
            (click)="startTunnel()"
            [disabled]="isLoading()"
          >
            {{ isLoading() ? '⏳ Starting...' : '🚀 Start Remote Access' }}
          </button>
        } @else {
          <div class="remote-info">
            <div class="url-section">
              <label>Public URL:</label>
              <div class="url-box">
                <code>{{ publicUrl() }}</code>
                <button class="btn-copy" (click)="copyUrl()">📋 Copy</button>
              </div>
            </div>
            
            @if (qrCode()) {
              <div class="qr-section">
                <label>Scan with Mobile:</label>
                <img [src]="qrCode()" alt="QR Code" class="qr-image" />
              </div>
            }
            
            <button 
              class="btn btn-danger" 
              (click)="stopTunnel()"
              [disabled]="isLoading()"
            >
              🛑 Stop Remote Access
            </button>
          </div>
        }
        
        @if (message()) {
          <p class="message" [class.error]="isError()">{{ message() }}</p>
        }
      </div>
    </div>
  `,
  styles: [`
    .settings-page {
      padding: 1.5rem;
    }

    .page-title {
      font-size: 1.5rem;
      font-weight: 700;
      color: #1e3a8a;
      margin-bottom: 1.5rem;
    }

    .card {
      background: white;
      border: 1px solid rgba(59, 130, 246, 0.15);
      border-radius: 16px;
      padding: 1.5rem;
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
    }

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 0.5rem;
    }

    .section-header h3 {
      margin: 0;
      font-size: 1.1rem;
      color: #1e3a8a;
    }

    .status-badge {
      padding: 0.25rem 0.75rem;
      border-radius: 20px;
      font-size: 0.8rem;
      font-weight: 600;
      background: #f1f5f9;
      color: #64748b;
    }

    .status-badge.active {
      background: #dcfce7;
      color: #16a34a;
    }

    .section-desc {
      color: #64748b;
      margin-bottom: 1.5rem;
    }

    .btn {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 10px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
    }

    .btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .btn-primary {
      background: linear-gradient(135deg, #3b82f6, #1d4ed8);
      color: white;
    }

    .btn-primary:hover:not(:disabled) {
      box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
    }

    .btn-danger {
      background: linear-gradient(135deg, #ef4444, #dc2626);
      color: white;
    }

    /* Remote Info */
    .remote-info {
      display: flex;
      flex-direction: column;
      gap: 1.5rem;
    }

    .url-section, .qr-section {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    .url-section label, .qr-section label {
      font-size: 0.85rem;
      color: #64748b;
      font-weight: 600;
    }

    .url-box {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      background: #f8fafc;
      padding: 0.75rem 1rem;
      border-radius: 10px;
      border: 1px solid rgba(59, 130, 246, 0.2);
    }

    .url-box code {
      flex: 1;
      font-family: 'JetBrains Mono', 'Consolas', monospace;
      color: #3b82f6;
      font-size: 0.9rem;
      word-break: break-all;
    }

    .btn-copy {
      padding: 0.4rem 0.8rem;
      background: #3b82f6;
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 0.8rem;
      cursor: pointer;
      transition: all 0.2s;
    }

    .btn-copy:hover {
      background: #1d4ed8;
    }

    .qr-image {
      width: 200px;
      height: 200px;
      border-radius: 10px;
      border: 2px solid rgba(59, 130, 246, 0.2);
    }

    .message {
      margin-top: 1rem;
      padding: 0.75rem;
      border-radius: 8px;
      background: #f0f9ff;
      color: #3b82f6;
      font-size: 0.9rem;
    }

    .message.error {
      background: #fef2f2;
      color: #ef4444;
    }

    /* Master Workflow */
    .workflow-section {
      margin-bottom: 1.5rem;
    }

    .master-crud-section {
      margin-bottom: 1.5rem;
    }

    .master-tabs {
      display: flex;
      gap: 0.5rem;
      margin-bottom: 1rem;
      flex-wrap: wrap;
    }

    .master-tab-btn {
      border: 1px solid rgba(59, 130, 246, 0.25);
      background: #f8fafc;
      color: #1e3a8a;
      border-radius: 10px;
      padding: 0.45rem 0.8rem;
      font-size: 0.85rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }

    .master-tab-btn.active {
      background: linear-gradient(135deg, #3b82f6, #1d4ed8);
      color: white;
      border-color: transparent;
    }

    .master-toolbar {
      display: flex;
      gap: 0.5rem;
      margin-bottom: 1rem;
    }

    .btn-light {
      background: #eef2ff;
      color: #1e3a8a;
    }

    .btn-light:hover:not(:disabled) {
      background: #dbeafe;
    }

    .master-loading,
    .master-empty {
      padding: 0.9rem 1rem;
      border-radius: 10px;
      background: #f8fafc;
      color: #64748b;
      font-size: 0.9rem;
      border: 1px dashed rgba(100, 116, 139, 0.35);
    }

    .master-table-wrap {
      overflow-x: auto;
      border: 1px solid rgba(59, 130, 246, 0.15);
      border-radius: 12px;
    }

    .master-table {
      width: 100%;
      border-collapse: collapse;
      min-width: 720px;
    }

    .master-table th,
    .master-table td {
      text-align: left;
      padding: 0.65rem 0.75rem;
      border-bottom: 1px solid #e2e8f0;
      font-size: 0.86rem;
    }

    .master-table th {
      color: #475569;
      background: #f8fafc;
      font-weight: 700;
    }

    .master-table tr.inactive {
      opacity: 0.6;
    }

    .category-pill {
      display: inline-block;
      padding: 0.2rem 0.5rem;
      border-radius: 999px;
      background: #eff6ff;
      color: #1d4ed8;
      font-size: 0.75rem;
      font-weight: 600;
    }

    .status-pill {
      display: inline-block;
      font-size: 0.75rem;
      font-weight: 600;
      border-radius: 999px;
      padding: 0.2rem 0.55rem;
      background: #fee2e2;
      color: #b91c1c;
    }

    .status-pill.active {
      background: #dcfce7;
      color: #166534;
    }

    .actions-cell {
      display: flex;
      gap: 0.35rem;
      flex-wrap: wrap;
    }

    .action-btn {
      border: 1px solid #cbd5e1;
      background: white;
      color: #334155;
      border-radius: 8px;
      padding: 0.25rem 0.5rem;
      font-size: 0.75rem;
      cursor: pointer;
    }

    .action-btn:hover {
      background: #f8fafc;
    }

    .action-btn.danger {
      color: #b91c1c;
      border-color: #fecaca;
      background: #fff5f5;
    }

    .master-editor {
      margin-top: 1rem;
      padding: 1rem;
      border-radius: 12px;
      border: 1px solid rgba(59, 130, 246, 0.2);
      background: #f8fbff;
      display: grid;
      gap: 0.55rem;
    }

    .master-editor h4 {
      margin: 0 0 0.35rem;
      color: #1e3a8a;
    }

    .editor-label {
      font-size: 0.8rem;
      color: #475569;
      font-weight: 600;
    }

    .editor-input {
      width: 100%;
      border: 1px solid #cbd5e1;
      border-radius: 8px;
      padding: 0.55rem 0.65rem;
      font-size: 0.9rem;
      background: white;
    }

    .editor-checkbox {
      margin-top: 0.3rem;
      display: inline-flex;
      align-items: center;
      gap: 0.45rem;
      font-size: 0.85rem;
      color: #334155;
    }

    .editor-actions {
      margin-top: 0.5rem;
      display: flex;
      gap: 0.5rem;
    }

    .master-info {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      padding: 0.75rem 1rem;
      background: linear-gradient(135deg, #fef3c7, #fde68a);
      border-radius: 10px;
      margin-bottom: 1rem;
    }

    .master-icon {
      font-size: 1.5rem;
    }

    .master-name {
      font-weight: 600;
      color: #92400e;
      flex: 1;
    }

    .master-steps {
      background: rgba(0, 0, 0, 0.1);
      padding: 0.25rem 0.5rem;
      border-radius: 6px;
      font-size: 0.75rem;
      color: #78350f;
    }
  `]
})
export class SettingsComponent implements OnInit, OnDestroy {
  private router = inject(Router);
  private http = inject(HttpClient);
  
  isConnected = signal(false);
  isLoading = signal(false);
  publicUrl = signal('');
  qrCode = signal('');
  message = signal('');
  isError = signal(false);
  masterWorkflow = signal<any>(null);

  masterTabs: { id: MasterTab; label: string; icon: string }[] = [
    { id: 'mode', label: 'Modes', icon: '🎮' },
    { id: 'step-type', label: 'Step Types', icon: '⚡' },
    { id: 'role', label: 'Roles', icon: '👥' },
  ];
  activeMasterTab = signal<MasterTab>('mode');
  masterItems = signal<MasterItem[]>([]);
  masterLoading = signal(false);
  masterError = signal('');
  isEditingMaster = signal(false);
  isSavingMaster = signal(false);
  editingMasterItem = signal<MasterItem | null>(null);
  masterForm: {
    code: string;
    display_name: string;
    description: string;
    icon: string;
    category: string;
    sort_order: number;
    is_active: boolean;
  } = {
    code: '',
    display_name: '',
    description: '',
    icon: '',
    category: 'action',
    sort_order: 0,
    is_active: true,
  };
  
  private pollingInterval: any;

  ngOnInit(): void {
    this.checkStatus();
    this.loadMasterWorkflow();
    this.loadMasterData();
    this.pollingInterval = setInterval(() => this.checkStatus(), 5000);
  }

  ngOnDestroy(): void {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval);
    }
  }

  async checkStatus(): Promise<void> {
    try {
      const response = await fetch('/api/v1/remote/status');
      const data = await response.json();
      
      this.isConnected.set(data.is_running);
      this.publicUrl.set(data.public_url || '');
      this.qrCode.set(data.qr_code || '');
    } catch (error) {
      // Silent fail for polling
    }
  }

  async startTunnel(): Promise<void> {
    this.isLoading.set(true);
    this.message.set('');
    
    try {
      const response = await fetch('/api/v1/remote/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ port: 8000 })
      });
      const data = await response.json();
      
      if (data.success) {
        this.isConnected.set(true);
        this.publicUrl.set(data.public_url);
        this.message.set('✅ Remote access started!');
        this.isError.set(false);
        this.checkStatus(); // Get QR code
      } else {
        this.message.set(`❌ ${data.message}`);
        this.isError.set(true);
      }
    } catch (error) {
      this.message.set(`❌ Error: ${error}`);
      this.isError.set(true);
    } finally {
      this.isLoading.set(false);
    }
  }

  async stopTunnel(): Promise<void> {
    this.isLoading.set(true);
    
    try {
      const response = await fetch('/api/v1/remote/stop', {
        method: 'POST'
      });
      const data = await response.json();
      
      if (data.success) {
        this.isConnected.set(false);
        this.publicUrl.set('');
        this.qrCode.set('');
        this.message.set('🔌 Remote access stopped');
        this.isError.set(false);
      }
    } catch (error) {
      this.message.set(`❌ Error: ${error}`);
      this.isError.set(true);
    } finally {
      this.isLoading.set(false);
    }
  }

  copyUrl(): void {
    navigator.clipboard.writeText(this.publicUrl())
      .then(() => {
        this.message.set('📋 URL copied to clipboard!');
        this.isError.set(false);
      })
      .catch(() => {
        this.message.set('❌ Failed to copy');
        this.isError.set(true);
      });
  }

  async loadMasterWorkflow(): Promise<void> {
    try {
      const response = await fetch('/api/v1/workflows/master');
      const data = await response.json();
      if (data.success && data.workflow) {
        this.masterWorkflow.set(data.workflow);
      }
    } catch (error) {
      // Silent fail
    }
  }

  goToWorkflowBuilder(): void {
    this.router.navigate(['/workflow-builder']);
  }

  private get masterEndpoint(): string {
    if (this.activeMasterTab() === 'mode') {
      return '/api/v1/master/modes';
    }
    if (this.activeMasterTab() === 'step-type') {
      return '/api/v1/master/step-types';
    }
    return '/api/v1/master/roles';
  }

  switchMasterTab(tab: MasterTab): void {
    this.activeMasterTab.set(tab);
    this.cancelMasterEdit();
    this.loadMasterData();
  }

  loadMasterData(): void {
    this.masterLoading.set(true);
    this.masterError.set('');

    this.http.get<{ success: boolean; data: MasterItem[] }>(this.masterEndpoint).subscribe({
      next: (res) => {
        this.masterItems.set(res.data ?? []);
        this.masterLoading.set(false);
      },
      error: (err) => {
        this.masterError.set(err?.error?.detail || 'โหลดข้อมูล master ไม่สำเร็จ');
        this.masterLoading.set(false);
      },
    });
  }

  startCreateMaster(): void {
    this.isEditingMaster.set(true);
    this.editingMasterItem.set(null);
    this.masterForm = {
      code: '',
      display_name: '',
      description: '',
      icon: '',
      category: 'action',
      sort_order: 0,
      is_active: true,
    };
  }

  startEditMaster(item: MasterItem): void {
    this.isEditingMaster.set(true);
    this.editingMasterItem.set(item);
    this.masterForm = {
      code: item.code,
      display_name: item.display_name,
      description: item.description || '',
      icon: item.icon || '',
      category: item.category || 'action',
      sort_order: item.sort_order,
      is_active: item.is_active,
    };
  }

  cancelMasterEdit(): void {
    this.isEditingMaster.set(false);
    this.editingMasterItem.set(null);
  }

  saveMasterItem(): void {
    if (!this.masterForm.display_name.trim()) {
      this.masterError.set('Display name ห้ามว่าง');
      return;
    }

    if (!this.editingMasterItem() && !this.masterForm.code.trim()) {
      this.masterError.set('Code ห้ามว่าง');
      return;
    }

    const payload: any = {
      display_name: this.masterForm.display_name.trim(),
      description: this.masterForm.description.trim() || null,
      icon: this.masterForm.icon.trim() || null,
      sort_order: Number(this.masterForm.sort_order) || 0,
      is_active: this.masterForm.is_active,
    };

    if (!this.editingMasterItem()) {
      payload.code = this.masterForm.code.trim();
    }

    if (this.activeMasterTab() === 'step-type') {
      payload.category = this.masterForm.category;
    }

    this.isSavingMaster.set(true);
    this.masterError.set('');

    const editing = this.editingMasterItem();
    const request$ = editing
      ? this.http.put(`${this.masterEndpoint}/${editing.id}`, payload)
      : this.http.post(this.masterEndpoint, payload);

    request$.subscribe({
      next: () => {
        this.isSavingMaster.set(false);
        this.cancelMasterEdit();
        this.loadMasterData();
      },
      error: (err) => {
        this.masterError.set(err?.error?.detail || 'บันทึกข้อมูลไม่สำเร็จ');
        this.isSavingMaster.set(false);
      },
    });
  }

  toggleMasterActive(item: MasterItem): void {
    this.masterError.set('');
    this.http
      .put(`${this.masterEndpoint}/${item.id}`, { is_active: !item.is_active })
      .subscribe({
        next: () => this.loadMasterData(),
        error: (err) => {
          this.masterError.set(err?.error?.detail || 'สลับสถานะไม่สำเร็จ');
        },
      });
  }

  deleteMasterItem(item: MasterItem): void {
    const confirmed = window.confirm(`Delete "${item.display_name}" (${item.code}) ?`);
    if (!confirmed) {
      return;
    }

    this.masterError.set('');
    this.http.delete(`${this.masterEndpoint}/${item.id}`).subscribe({
      next: () => this.loadMasterData(),
      error: (err) => {
        this.masterError.set(err?.error?.detail || 'ลบข้อมูลไม่สำเร็จ');
      },
    });
  }
}
