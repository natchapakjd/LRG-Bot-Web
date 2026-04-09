import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import Swal from 'sweetalert2';

interface MasterItem {
  id: number;
  code: string;
  display_name: string;
  description?: string;
  icon?: string;
  category?: string;
  is_active: boolean;
  sort_order: number;
}

type TabType = 'mode' | 'step-type' | 'role';

@Component({
  selector: 'app-master-data',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="master-container">
      <div class="page-header glass-panel">
        <div class="header-content">
          <div class="title-area">
            <span class="page-icon">🗂️</span>
            <div>
              <h2 class="page-title">Master Data</h2>
              <p class="page-subtitle">จัดการข้อมูล Lookup / Reference ของระบบ</p>
            </div>
          </div>
        </div>

        <!-- Tabs -->
        <div class="tab-bar">
          @for (tab of tabs; track tab.id) {
            <button
              class="tab-btn"
              [class.active]="activeTab === tab.id"
              (click)="switchTab(tab.id)"
            >
              <span>{{ tab.icon }}</span> {{ tab.label }}
            </button>
          }
        </div>
      </div>

      <!-- Table Section -->
      <div class="table-section glass-panel">
        <div class="section-header">
          <h3>{{ currentTabMeta.label }}</h3>
          <button class="add-btn glass-button" (click)="openCreateDialog()">
            ＋ เพิ่มรายการ
          </button>
        </div>

        @if (loading()) {
          <div class="loading-overlay"><span class="spinner">⏳</span> กำลังโหลด...</div>
        } @else if (items().length === 0) {
          <div class="empty-state">ไม่มีข้อมูล – กดปุ่ม "เพิ่มรายการ" เพื่อสร้างข้อมูลแรก</div>
        } @else {
          <div class="table-wrapper">
            <table class="data-table">
              <thead>
                <tr>
                  <th class="col-id">ID</th>
                  <th class="col-icon">Icon</th>
                  <th class="col-code">Code</th>
                  <th class="col-name">Display Name</th>
                  @if (activeTab === 'step-type') { <th class="col-cat">Category</th> }
                  <th class="col-desc">Description</th>
                  <th class="col-order">Sort</th>
                  <th class="col-status">Status</th>
                  <th class="col-actions">Actions</th>
                </tr>
              </thead>
              <tbody>
                @for (item of items(); track item.id) {
                  <tr [class.inactive-row]="!item.is_active">
                    <td class="col-id">{{ item.id }}</td>
                    <td class="col-icon">{{ item.icon || '–' }}</td>
                    <td class="col-code"><code>{{ item.code }}</code></td>
                    <td class="col-name">{{ item.display_name }}</td>
                    @if (activeTab === 'step-type') {
                      <td class="col-cat">
                        <span class="badge badge-{{ item.category }}">{{ item.category }}</span>
                      </td>
                    }
                    <td class="col-desc text-muted">{{ item.description || '–' }}</td>
                    <td class="col-order">{{ item.sort_order }}</td>
                    <td class="col-status">
                      <span class="status-pill" [class.active]="item.is_active">
                        {{ item.is_active ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td class="col-actions">
                      <button class="icon-btn edit-btn" title="Edit" (click)="openEditDialog(item)">✏️</button>
                      <button class="icon-btn toggle-btn" title="Toggle active" (click)="toggleActive(item)">
                        {{ item.is_active ? '🔴' : '🟢' }}
                      </button>
                      <button class="icon-btn del-btn" title="Delete" (click)="deleteItem(item)">🗑️</button>
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        }
      </div>
    </div>
  `,
  styles: [`
    :host { display: block; padding: 1.5rem; }

    .master-container { display: flex; flex-direction: column; gap: 1.5rem; }

    /* Header */
    .page-header { padding: 1.5rem 1.5rem 0; }
    .header-content { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.25rem; }
    .title-area { display: flex; align-items: center; gap: 1rem; }
    .page-icon { font-size: 2rem; }
    .page-title { font-size: 1.5rem; font-weight: 700; color: var(--text-main); margin: 0; }
    .page-subtitle { font-size: 0.85rem; color: var(--text-muted); margin: 0.25rem 0 0; }

    /* Tabs */
    .tab-bar {
      display: flex;
      gap: 0;
      border-top: 1px solid rgba(255,255,255,0.06);
      margin: 0 -1.5rem;
      padding: 0 1.5rem;
      overflow-x: auto;
    }

    .tab-btn {
      background: none;
      border: none;
      border-bottom: 3px solid transparent;
      color: var(--text-muted);
      font-size: 0.9rem;
      font-weight: 500;
      padding: 0.85rem 1.25rem;
      cursor: pointer;
      white-space: nowrap;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .tab-btn:hover { color: var(--text-main); }
    .tab-btn.active { color: var(--primary); border-bottom-color: var(--primary); }

    /* Table section */
    .table-section { padding: 1.5rem; }
    .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; }
    .section-header h3 { margin: 0; font-size: 1.1rem; color: var(--text-main); }

    .add-btn {
      background: var(--grad-primary);
      border: none;
      border-radius: 8px;
      color: #fff;
      font-weight: 600;
      padding: 0.5rem 1.25rem;
      cursor: pointer;
      font-size: 0.9rem;
      transition: opacity 0.2s;
    }
    .add-btn:hover { opacity: 0.85; }

    .loading-overlay, .empty-state {
      text-align: center;
      padding: 3rem;
      color: var(--text-muted);
      font-size: 0.95rem;
    }
    .spinner { font-size: 1.5rem; }

    /* Table */
    .table-wrapper { overflow-x: auto; }
    .data-table { width: 100%; border-collapse: collapse; }
    .data-table th, .data-table td {
      padding: 0.65rem 0.85rem;
      text-align: left;
      border-bottom: 1px solid rgba(255,255,255,0.05);
    }
    .data-table th { color: var(--text-muted); font-size: 0.78rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
    .data-table td { font-size: 0.88rem; color: var(--text-main); }
    .data-table tbody tr:hover { background: rgba(255,255,255,0.03); }
    .inactive-row { opacity: 0.45; }

    .col-id    { width: 48px; }
    .col-icon  { width: 48px; text-align: center; }
    .col-code  { width: 160px; }
    .col-name  { min-width: 140px; }
    .col-cat   { width: 110px; }
    .col-desc  { }
    .col-order { width: 60px; text-align: center; }
    .col-status{ width: 90px; }
    .col-actions { width: 110px; }

    code { font-family: monospace; background: rgba(255,255,255,0.06); padding: 2px 6px; border-radius: 4px; font-size: 0.82rem; color: var(--primary); }
    .text-muted { color: var(--text-muted); font-size: 0.82rem; }

    /* Badges */
    .badge { font-size: 0.75rem; padding: 2px 8px; border-radius: 10px; font-weight: 600; }
    .badge-action    { background: rgba(0,198,255,0.15); color: #00c6ff; }
    .badge-detection { background: rgba(161,140,209,0.2); color: #b39ddb; }
    .badge-control   { background: rgba(255,193,7,0.15); color: #ffc107; }
    .badge-loop      { background: rgba(76,175,80,0.15); color: #81c784; }

    /* Status pill */
    .status-pill { font-size: 0.75rem; padding: 2px 8px; border-radius: 10px; background: rgba(255,59,48,0.12); color: #ff3b30; font-weight: 600; }
    .status-pill.active { background: rgba(52,199,89,0.15); color: #34c759; }

    /* Action buttons */
    .icon-btn { background: none; border: none; cursor: pointer; padding: 4px 5px; font-size: 1.05rem; border-radius: 6px; transition: background 0.15s; }
    .icon-btn:hover { background: rgba(255,255,255,0.08); }
  `]
})
export class MasterDataComponent implements OnInit {
  private apiBase = '/api/v1/master';

  tabs: { id: TabType; label: string; icon: string }[] = [
    { id: 'mode',      label: 'Game Modes',       icon: '🎮' },
    { id: 'step-type', label: 'Step Types',        icon: '⚡' },
    { id: 'role',      label: 'User Roles',        icon: '👥' },
  ];

  activeTab: TabType = 'mode';
  items = signal<MasterItem[]>([]);
  loading = signal(false);

  get currentTabMeta() {
    return this.tabs.find(t => t.id === this.activeTab)!;
  }

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.loadItems();
  }

  switchTab(tab: TabType) {
    this.activeTab = tab;
    this.loadItems();
  }

  private get endpoint(): string {
    const map: Record<TabType, string> = {
      mode: 'modes',
      'step-type': 'step-types',
      role: 'roles',
    };
    return `${this.apiBase}/${map[this.activeTab]}`;
  }

  loadItems() {
    this.loading.set(true);
    this.http.get<{ success: boolean; data: MasterItem[] }>(this.endpoint).subscribe({
      next: res => { this.items.set(res.data ?? []); this.loading.set(false); },
      error: () => { this.loading.set(false); }
    });
  }

  async openCreateDialog() {
    const isStepType = this.activeTab === 'step-type';

    const { value: formValues } = await Swal.fire({
      title: `เพิ่ม ${this.currentTabMeta.label}`,
      background: 'var(--bg-surface, #1a1f2e)',
      color: 'var(--text-main, #e8eaf0)',
      html: `
        <div style="display:flex;flex-direction:column;gap:10px;text-align:left">
          <label style="font-size:0.82rem;color:#aaa">Code *</label>
          <input id="sw-code" class="swal2-input" placeholder="เช่น daily-login" style="margin:0">
          <label style="font-size:0.82rem;color:#aaa">Display Name *</label>
          <input id="sw-name" class="swal2-input" placeholder="ชื่อแสดงผล" style="margin:0">
          <label style="font-size:0.82rem;color:#aaa">Description</label>
          <input id="sw-desc" class="swal2-input" placeholder="คำอธิบาย (ไม่บังคับ)" style="margin:0">
          <label style="font-size:0.82rem;color:#aaa">Icon (Emoji)</label>
          <input id="sw-icon" class="swal2-input" placeholder="🎮" style="margin:0;width:80px">
          ${isStepType ? `
          <label style="font-size:0.82rem;color:#aaa">Category</label>
          <select id="sw-cat" class="swal2-input" style="margin:0">
            <option value="action">action</option>
            <option value="detection">detection</option>
            <option value="control">control</option>
            <option value="loop">loop</option>
          </select>` : ''}
          <label style="font-size:0.82rem;color:#aaa">Sort Order</label>
          <input id="sw-sort" class="swal2-input" type="number" value="0" style="margin:0">
        </div>
      `,
      focusConfirm: false,
      showCancelButton: true,
      confirmButtonText: 'บันทึก',
      cancelButtonText: 'ยกเลิก',
      preConfirm: () => {
        const code = (document.getElementById('sw-code') as HTMLInputElement).value.trim();
        const name = (document.getElementById('sw-name') as HTMLInputElement).value.trim();
        if (!code || !name) { Swal.showValidationMessage('กรุณากรอก Code และ Display Name'); return; }
        const payload: any = {
          code,
          display_name: name,
          description: (document.getElementById('sw-desc') as HTMLInputElement).value.trim() || null,
          icon: (document.getElementById('sw-icon') as HTMLInputElement).value.trim() || null,
          sort_order: parseInt((document.getElementById('sw-sort') as HTMLInputElement).value) || 0,
          is_active: true,
        };
        if (isStepType) payload['category'] = (document.getElementById('sw-cat') as HTMLSelectElement).value;
        return payload;
      }
    });

    if (!formValues) return;

    this.http.post<{ success: boolean; data: MasterItem }>(this.endpoint, formValues).subscribe({
      next: res => {
        this.items.update(list => [...list, res.data]);
        Swal.fire({ icon: 'success', title: 'เพิ่มสำเร็จ', timer: 1200, showConfirmButton: false, background: 'var(--bg-surface,#1a1f2e)', color: 'var(--text-main,#e8eaf0)' });
      },
      error: err => Swal.fire({ icon: 'error', title: 'Error', text: err?.error?.detail ?? 'เกิดข้อผิดพลาด', background: 'var(--bg-surface,#1a1f2e)', color: 'var(--text-main,#e8eaf0)' })
    });
  }

  async openEditDialog(item: MasterItem) {
    const isStepType = this.activeTab === 'step-type';

    const { value: formValues } = await Swal.fire({
      title: `แก้ไข: ${item.code}`,
      background: 'var(--bg-surface, #1a1f2e)',
      color: 'var(--text-main, #e8eaf0)',
      html: `
        <div style="display:flex;flex-direction:column;gap:10px;text-align:left">
          <label style="font-size:0.82rem;color:#aaa">Display Name *</label>
          <input id="sw-name" class="swal2-input" value="${item.display_name}" style="margin:0">
          <label style="font-size:0.82rem;color:#aaa">Description</label>
          <input id="sw-desc" class="swal2-input" value="${item.description ?? ''}" style="margin:0">
          <label style="font-size:0.82rem;color:#aaa">Icon (Emoji)</label>
          <input id="sw-icon" class="swal2-input" value="${item.icon ?? ''}" style="margin:0;width:80px">
          ${isStepType ? `
          <label style="font-size:0.82rem;color:#aaa">Category</label>
          <select id="sw-cat" class="swal2-input" style="margin:0">
            <option value="action" ${item.category === 'action' ? 'selected' : ''}>action</option>
            <option value="detection" ${item.category === 'detection' ? 'selected' : ''}>detection</option>
            <option value="control" ${item.category === 'control' ? 'selected' : ''}>control</option>
            <option value="loop" ${item.category === 'loop' ? 'selected' : ''}>loop</option>
          </select>` : ''}
          <label style="font-size:0.82rem;color:#aaa">Sort Order</label>
          <input id="sw-sort" class="swal2-input" type="number" value="${item.sort_order}" style="margin:0">
        </div>
      `,
      focusConfirm: false,
      showCancelButton: true,
      confirmButtonText: 'บันทึก',
      cancelButtonText: 'ยกเลิก',
      preConfirm: () => {
        const name = (document.getElementById('sw-name') as HTMLInputElement).value.trim();
        if (!name) { Swal.showValidationMessage('กรุณากรอก Display Name'); return; }
        const payload: any = {
          display_name: name,
          description: (document.getElementById('sw-desc') as HTMLInputElement).value.trim() || null,
          icon: (document.getElementById('sw-icon') as HTMLInputElement).value.trim() || null,
          sort_order: parseInt((document.getElementById('sw-sort') as HTMLInputElement).value) || 0,
        };
        if (isStepType) payload['category'] = (document.getElementById('sw-cat') as HTMLSelectElement).value;
        return payload;
      }
    });

    if (!formValues) return;

    this.http.put<{ success: boolean; data: MasterItem }>(`${this.endpoint}/${item.id}`, formValues).subscribe({
      next: res => {
        this.items.update(list => list.map(i => i.id === item.id ? res.data : i));
        Swal.fire({ icon: 'success', title: 'บันทึกสำเร็จ', timer: 1200, showConfirmButton: false, background: 'var(--bg-surface,#1a1f2e)', color: 'var(--text-main,#e8eaf0)' });
      },
      error: err => Swal.fire({ icon: 'error', title: 'Error', text: err?.error?.detail ?? 'เกิดข้อผิดพลาด', background: 'var(--bg-surface,#1a1f2e)', color: 'var(--text-main,#e8eaf0)' })
    });
  }

  toggleActive(item: MasterItem) {
    this.http.put<{ success: boolean; data: MasterItem }>(`${this.endpoint}/${item.id}`, { is_active: !item.is_active }).subscribe({
      next: res => this.items.update(list => list.map(i => i.id === item.id ? res.data : i)),
    });
  }

  async deleteItem(item: MasterItem) {
    const result = await Swal.fire({
      title: 'ยืนยันการลบ?',
      text: `จะลบ "${item.display_name}" (${item.code})`,
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'ลบ',
      cancelButtonText: 'ยกเลิก',
      confirmButtonColor: '#ff3b30',
      background: 'var(--bg-surface,#1a1f2e)',
      color: 'var(--text-main,#e8eaf0)',
    });

    if (!result.isConfirmed) return;

    this.http.delete(`${this.endpoint}/${item.id}`).subscribe({
      next: () => {
        this.items.update(list => list.filter(i => i.id !== item.id));
        Swal.fire({ icon: 'success', title: 'ลบสำเร็จ', timer: 1200, showConfirmButton: false, background: 'var(--bg-surface,#1a1f2e)', color: 'var(--text-main,#e8eaf0)' });
      },
      error: err => Swal.fire({ icon: 'error', title: 'Error', text: err?.error?.detail ?? 'เกิดข้อผิดพลาด', background: 'var(--bg-surface,#1a1f2e)', color: 'var(--text-main,#e8eaf0)' })
    });
  }
}
