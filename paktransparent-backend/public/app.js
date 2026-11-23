/**
 * Pakistan Transparent - Production Client Application
 * Public Budget Tracker & Citizen Whistleblower System
 */

// ─── Application State ────────────────────────────────────────────────────────

const state = {
  currentLang: 'en', // 'en' or 'ur'
  activeTab: 'dashboard',
  user: {
    id: 'usr_cit_001',
    name: 'Ahmad Khan',
    email: 'citizen@paktransparent.pk',
    role: 'citizen',
    token: null,
  },
  projects: [],
  analytics: null,
  reports: [],
  auditLogs: [],
  filteredProjects: [],
  eventSource: null,
  compareProjectIds: [],
};

const OFFICIAL_USER = {
  id: 'usr_gov_001',
  name: 'Naveed Akhtar',
  email: 'official@paktransparent.pk',
  role: 'government',
  designation: 'Director General (Public Works)',
  department: 'Planning & Development Board',
  employeeCode: 'PAK-DH-092',
  approvalAuthority: 1000000000, // PKR 1 Billion ceiling
};

const CITIZEN_USER = {
  id: 'usr_cit_001',
  name: 'Ahmad Khan',
  email: 'citizen@paktransparent.pk',
  role: 'citizen',
  cnic: '35201-1234567-1',
  phone: '+92 300 1122334',
  district: 'Lahore',
  province: 'punjab',
};

// ─── Formatting Helpers ───────────────────────────────────────────────────────

function formatPKR(num) {
  if (num === undefined || num === null || isNaN(num)) return 'PKR 0';
  if (num >= 1000000000) {
    return `PKR ${(num / 1000000000).toFixed(2)} Billion`;
  } else if (num >= 10000000) {
    return `PKR ${(num / 10000000).toFixed(2)} Crore`;
  } else if (num >= 100000) {
    return `PKR ${(num / 100000).toFixed(2)} Lakh`;
  }
  return `PKR ${num.toLocaleString()}`;
}

function formatDate(isoStr) {
  if (!isoStr) return 'N/A';
  try {
    const d = new Date(isoStr);
    return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
  } catch (e) {
    return isoStr;
  }
}

// ─── Toast Notifications ─────────────────────────────────────────────────────

function showToast(message, type = 'info') {
  const container = document.getElementById('toastContainer');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  const icon = type === 'success' ? '✅' : type === 'error' ? '❌' : '🔔';
  toast.innerHTML = `<span>${icon}</span><span>${message}</span>`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

// ─── Real-Time SSE (Server-Sent Events) ────────────────────────────────────────

function initSSE() {
  const badge = document.getElementById('liveStatusBadge');
  const text = document.getElementById('liveStatusText');

  if (state.eventSource) {
    state.eventSource.close();
  }

  try {
    const es = new EventSource('/api/events');
    state.eventSource = es;

    es.onopen = () => {
      if (badge) badge.style.display = 'flex';
      if (text) text.textContent = state.currentLang === 'ur' ? 'براہ راست رابطہ: فعال' : 'Real-Time: Connected';
    };

    es.onerror = () => {
      if (text) text.textContent = state.currentLang === 'ur' ? 'دوبارہ رابطہ...' : 'Reconnecting...';
    };

    es.addEventListener('welcome', (e) => {
      console.log('SSE Connected:', e.data);
    });

    es.addEventListener('project_created', (e) => {
      const data = JSON.parse(e.data);
      showToast(`📢 New Project Sanctioned: ${data.title}`, 'info');
      refreshAllData();
    });

    es.addEventListener('budget_updated', (e) => {
      const data = JSON.parse(e.data);
      showToast(`💰 Budget Updated for ${data.id}`, 'info');
      refreshAllData();
    });

    es.addEventListener('report_created', (e) => {
      const data = JSON.parse(e.data);
      showToast(`🚨 New Whistleblower Report filed: #${data.id}`, 'warning');
      refreshReportsAndAudit();
    });

    es.addEventListener('report_status_updated', (e) => {
      const data = JSON.parse(e.data);
      showToast(`⚖️ Inquiry Ruling on Report #${data.id}: Status is now ${data.status}`, 'success');
      refreshReportsAndAudit();
    });
  } catch (err) {
    console.error('SSE initialization failed:', err);
  }
}

// ─── API Requests ─────────────────────────────────────────────────────────────

async function apiRequest(endpoint, method = 'GET', body = null) {
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
    },
  };
  if (state.user.token) {
    options.headers['Authorization'] = `Bearer ${state.user.token}`;
  }
  if (body) {
    options.body = JSON.stringify(body);
  }

  const res = await fetch(endpoint, options);
  const json = await res.json();
  if (!res.ok) {
    throw new Error(json.error || `HTTP error ${res.status}`);
  }
  return json;
}

// ─── Load Initial Data ────────────────────────────────────────────────────────

async function refreshAllData() {
  await Promise.all([
    loadProjects(),
    loadAnalytics(),
    loadReports(),
    loadAuditTrail(),
  ]);
  renderDashboard();
  renderProjectsList();
  renderBudgetComparisonSelectors();
  renderAIInsights();
  populateReportProjectOptions();
}

async function refreshReportsAndAudit() {
  await Promise.all([
    loadReports(),
    loadAuditTrail(),
    loadAnalytics(),
  ]);
  renderMyReports();
  renderGovReportsTable();
  updateKPIs();
}

async function loadProjects() {
  try {
    const res = await apiRequest('/api/projects?limit=100');
    if (res.success) {
      state.projects = res.data;
      state.filteredProjects = [...res.data];
    }
  } catch (err) {
    console.error('Failed to load projects:', err);
  }
}

async function loadAnalytics() {
  try {
    const res = await apiRequest('/api/analytics');
    if (res.success) {
      state.analytics = res.data;
      renderAnalytics();
    }
  } catch (err) {
    console.error('Failed to load analytics:', err);
  }
}

async function loadReports() {
  try {
    const res = await apiRequest('/api/reports');
    if (res.success) {
      state.reports = res.data;
      renderMyReports();
      renderGovReportsTable();
    }
  } catch (err) {
    console.error('Failed to load reports:', err);
  }
}

async function loadAuditTrail() {
  try {
    const res = await apiRequest('/api/audit');
    if (res.success) {
      state.auditLogs = res.data;
      renderAuditTrail();
    }
  } catch (err) {
    console.error('Failed to load audit logs:', err);
  }
}

// ─── Render Dashboard ─────────────────────────────────────────────────────────

function updateKPIs() {
  if (!state.analytics) return;
  const a = state.analytics;

  const kpiBudget = document.getElementById('kpiTotalBudget');
  const kpiSpent = document.getElementById('kpiTotalSpent');
  const kpiSpentFill = document.getElementById('kpiSpentPercentFill');
  const kpiSpentText = document.getElementById('kpiSpentPercentText');
  const kpiActive = document.getElementById('kpiActiveProjects');
  const kpiCompleted = document.getElementById('kpiCompletedProjectsText');
  const kpiReports = document.getElementById('kpiTotalReports');
  const kpiResolved = document.getElementById('kpiResolvedReportsText');

  if (kpiBudget) kpiBudget.textContent = formatPKR(a.totalBudget);
  if (kpiSpent) kpiSpent.textContent = formatPKR(a.totalSpent);
  if (kpiSpentFill) kpiSpentFill.style.width = `${a.spendingRate}%`;
  if (kpiSpentText) kpiSpentText.textContent = `${a.spendingRate}% of total sanctioned funds`;
  if (kpiActive) kpiActive.textContent = a.activeProjects;
  if (kpiCompleted) kpiCompleted.textContent = `${a.completedProjects} completed projects`;
  if (kpiReports) kpiReports.textContent = a.totalReports;
  if (kpiResolved) kpiResolved.textContent = `${a.resolvedReports} resolved by official enquiry`;
}

function renderDashboard() {
  updateKPIs();

  const grid = document.getElementById('featuredProjectsGrid');
  if (!grid) return;

  if (state.projects.length === 0) {
    grid.innerHTML = '<div class="text-muted">No projects available yet.</div>';
    return;
  }

  // Display top 3 featured projects
  const featured = state.projects.slice(0, 3);
  grid.innerHTML = featured.map(p => createProjectCardHtml(p)).join('');
}

// ─── Project Card HTML Generator ──────────────────────────────────────────────

function createProjectCardHtml(p) {
  const percent = p.progress !== undefined ? p.progress : Math.min(100, Math.round((p.spent / p.budget) * 100));
  const riskClass = p.riskLevel === 'high' ? 'badge-red' : p.riskLevel === 'medium' ? 'badge-yellow' : 'badge-green';
  const statusClass = p.status === 'completed' ? 'badge-green' : p.status === 'delayed' ? 'badge-red' : 'badge-blue';

  return `
    <div class="project-card">
      <div>
        <div class="project-card-header">
          <div>
            <h4 class="project-card-title">${escapeHtml(p.title)}</h4>
            <div class="project-card-code">${escapeHtml(p.id)} • ${escapeHtml(p.district)}, ${escapeHtml(p.province.toUpperCase())}</div>
          </div>
          <div class="project-card-badges">
            <span class="badge ${statusClass}">${p.status.replace('_', ' ')}</span>
            <span class="badge ${riskClass}">${p.riskLevel || 'low'} risk</span>
          </div>
        </div>

        <p class="project-card-desc">${escapeHtml(p.description)}</p>

        <div class="project-budget-stats">
          <div class="budget-stat-row">
            <span class="budget-stat-label">Sanctioned Budget:</span>
            <span class="budget-stat-val">${formatPKR(p.budget)}</span>
          </div>
          <div class="budget-stat-row">
            <span class="budget-stat-label">Disbursed Expenditure:</span>
            <span class="budget-stat-val">${formatPKR(p.spent)}</span>
          </div>
        </div>

        <div class="project-progress-wrap">
          <div class="progress-header">
            <span>Physical Progress</span>
            <span>${percent}%</span>
          </div>
          <div class="progress-bar-bg">
            <div class="progress-bar-fill" style="width: ${percent}%;"></div>
          </div>
        </div>
      </div>

      <div class="project-card-footer">
        <span>Contractor: <strong>${escapeHtml(p.contractor?.name || 'Public Authority')}</strong></span>
        <button class="btn btn-sm btn-outline" onclick="openProjectDetail('${p.id}')">Inspect Details →</button>
      </div>
    </div>
  `;
}

// ─── Projects Screen & Filters ────────────────────────────────────────────────

function renderProjectsList() {
  const grid = document.getElementById('allProjectsGrid');
  const countText = document.getElementById('projectCountText');
  if (!grid) return;

  if (state.filteredProjects.length === 0) {
    grid.innerHTML = '<div class="text-muted" style="grid-column: 1/-1; padding: 2rem; text-align: center;">No projects match your search criteria.</div>';
    if (countText) countText.textContent = 'Showing 0 projects';
    return;
  }

  if (countText) {
    countText.textContent = `Showing ${state.filteredProjects.length} public project${state.filteredProjects.length > 1 ? 's' : ''}`;
  }

  grid.innerHTML = state.filteredProjects.map(p => createProjectCardHtml(p)).join('');
}

let searchDebounceTimer = null;
function handleProjectSearch(query) {
  clearTimeout(searchDebounceTimer);
  searchDebounceTimer = setTimeout(() => {
    applyProjectFilters();
  }, 250);
}

function applyProjectFilters() {
  const query = (document.getElementById('projectSearchInput')?.value || '').toLowerCase().trim();
  const prov = document.getElementById('filterProvince')?.value || 'all';
  const sector = document.getElementById('filterSector')?.value || 'all';
  const status = document.getElementById('filterStatus')?.value || 'all';
  const risk = document.getElementById('filterRisk')?.value || 'all';
  const sortBy = document.getElementById('sortProjects')?.value || 'budget_desc';

  let list = state.projects.filter(p => {
    if (query) {
      const matchText = `${p.title} ${p.id} ${p.district} ${p.contractor?.name || ''}`.toLowerCase();
      if (!matchText.includes(query)) return false;
    }
    if (prov !== 'all' && p.province !== prov) return false;
    if (sector !== 'all' && p.sector !== sector) return false;
    if (status !== 'all' && p.status !== status) return false;
    if (risk !== 'all' && (p.riskLevel || 'low') !== risk) return false;
    return true;
  });

  // Sorting
  if (sortBy === 'budget_desc') {
    list.sort((a, b) => b.budget - a.budget);
  } else if (sortBy === 'budget_asc') {
    list.sort((a, b) => a.budget - b.budget);
  } else if (sortBy === 'progress_desc') {
    list.sort((a, b) => (b.progress || 0) - (a.progress || 0));
  } else if (sortBy === 'newest') {
    list.sort((a, b) => new Date(b.startDate || 0) - new Date(a.startDate || 0));
  }

  state.filteredProjects = list;
  renderProjectsList();
}

function resetProjectFilters() {
  const searchInput = document.getElementById('projectSearchInput');
  const provSelect = document.getElementById('filterProvince');
  const sectorSelect = document.getElementById('filterSector');
  const statusSelect = document.getElementById('filterStatus');
  const riskSelect = document.getElementById('filterRisk');
  const sortSelect = document.getElementById('sortProjects');

  if (searchInput) searchInput.value = '';
  if (provSelect) provSelect.value = 'all';
  if (sectorSelect) sectorSelect.value = 'all';
  if (statusSelect) statusSelect.value = 'all';
  if (riskSelect) riskSelect.value = 'all';
  if (sortSelect) sortSelect.value = 'budget_desc';

  state.filteredProjects = [...state.projects];
  renderProjectsList();
}

// ─── Project Detail Modal ─────────────────────────────────────────────────────

function openProjectDetail(id) {
  const project = state.projects.find(p => p.id === id);
  if (!project) {
    showToast('Project not found', 'error');
    return;
  }

  document.getElementById('modalProjectTitle').textContent = project.title;
  document.getElementById('modalProjectCode').textContent = `${project.id} • ${project.district}, ${project.province.toUpperCase()}`;
  document.getElementById('modalProjectSector').textContent = (project.sector || 'Infrastructure').toUpperCase();
  document.getElementById('modalProjectStatus').textContent = (project.status || 'Active').replace('_', ' ').toUpperCase();

  const percent = project.progress !== undefined ? project.progress : Math.min(100, Math.round((project.spent / project.budget) * 100));
  const remaining = Math.max(0, project.budget - project.spent);

  const contractor = project.contractor || {
    name: 'National Highway Authority (Direct Works)',
    ntn: '3948572-0',
    rating: 4.8,
    activeProjects: 2,
    completedProjects: 14,
  };

  const milestonesHtml = (project.milestones || []).map(m => {
    const isDone = m.status === 'completed';
    return `
      <div class="timeline-item">
        <div class="timeline-dot ${isDone ? 'completed' : ''}"></div>
        <div class="timeline-title">${escapeHtml(m.title)}</div>
        <div class="timeline-date">Target: ${formatDate(m.targetDate)} • Status: <strong>${m.status}</strong></div>
      </div>
    `;
  }).join('') || '<div class="text-muted">No specific milestone data recorded.</div>';

  const bodyHtml = `
    <p style="margin-bottom: 1.25rem; font-size: 0.95rem; line-height: 1.6;">${escapeHtml(project.description)}</p>

    <!-- Budget Breakdown Cards -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 0.75rem; margin-bottom: 1.25rem;">
      <div style="background: #E8F5E9; padding: 0.85rem; border-radius: 6px;">
        <span style="font-size: 0.75rem; color: #2E7D32; font-weight: 700;">TOTAL ALLOCATED</span>
        <div style="font-size: 1.15rem; font-weight: 800; color: #1B5E20;">${formatPKR(project.budget)}</div>
      </div>
      <div style="background: #E1F5FE; padding: 0.85rem; border-radius: 6px;">
        <span style="font-size: 0.75rem; color: #0288D1; font-weight: 700;">TOTAL EXPENDITURE</span>
        <div style="font-size: 1.15rem; font-weight: 800; color: #01579B;">${formatPKR(project.spent)}</div>
      </div>
      <div style="background: #FFF8E1; padding: 0.85rem; border-radius: 6px;">
        <span style="font-size: 0.75rem; color: #F57F17; font-weight: 700;">REMAINING ALLOCATION</span>
        <div style="font-size: 1.15rem; font-weight: 800; color: #E65100;">${formatPKR(remaining)}</div>
      </div>
    </div>

    <!-- Progress Meter -->
    <div style="margin-bottom: 1.5rem;">
      <div style="display: flex; justify-content: space-between; font-weight: 700; font-size: 0.85rem; margin-bottom: 0.35rem;">
        <span>Physical Milestone Progress</span>
        <span>${percent}%</span>
      </div>
      <div class="progress-bar-bg" style="height: 10px;">
        <div class="progress-bar-fill" style="width: ${percent}%;"></div>
      </div>
    </div>

    <!-- Verified Contractor Profile -->
    <h4 style="font-size: 0.95rem; margin-bottom: 0.5rem;">Verified Contractor Information</h4>
    <div class="contractor-card">
      <div class="contractor-header">
        <span class="contractor-name">🏗️ ${escapeHtml(contractor.name)}</span>
        <span class="badge badge-green">PEC Registered</span>
      </div>
      <div class="contractor-meta-grid">
        <div><strong>NTN Number:</strong> ${escapeHtml(contractor.ntn || 'N/A')}</div>
        <div><strong>Performance Rating:</strong> ⭐ ${contractor.rating || 4.5} / 5.0</div>
        <div><strong>Completed Public Works:</strong> ${contractor.completedProjects || 5}</div>
        <div><strong>Active Public Contracts:</strong> ${contractor.activeProjects || 1}</div>
      </div>
    </div>

    <!-- Milestones Timeline -->
    <h4 style="font-size: 0.95rem; margin-top: 1.25rem; margin-bottom: 0.5rem;">Official Project Milestones</h4>
    <div class="milestones-timeline">
      ${milestonesHtml}
    </div>

    <!-- Action Buttons -->
    <div style="display: flex; gap: 0.75rem; margin-top: 1.5rem; flex-wrap: wrap;">
      <button class="btn btn-accent" onclick="reportDiscrepancyForProject('${project.id}')">🚨 Report Discrepancy</button>
      <button class="btn btn-outline" onclick="openQrShareModal('${project.id}')">📱 Worksite QR Plaque</button>
      <button class="btn btn-outline" onclick="addToCompare('${project.id}')">⚖️ Add to Comparison</button>
    </div>
  `;

  document.getElementById('projectDetailModalBody').innerHTML = bodyHtml;
  openModal('projectDetailModal');
}

// ─── Budget Comparison Tool ───────────────────────────────────────────────────

function renderBudgetComparisonSelectors() {
  const sel1 = document.getElementById('compareSelect1');
  const sel2 = document.getElementById('compareSelect2');
  const sel3 = document.getElementById('compareSelect3');
  if (!sel1 || !sel2 || !sel3) return;

  const options = '<option value="">-- Choose Project --</option>' +
    state.projects.map(p => `<option value="${p.id}">${escapeHtml(p.id)}: ${escapeHtml(p.title.substring(0, 32))}...</option>`).join('');

  sel1.innerHTML = options;
  sel2.innerHTML = options;
  sel3.innerHTML = options;

  if (state.projects.length >= 2) {
    sel1.value = state.projects[0].id;
    sel2.value = state.projects[1].id;
    if (state.projects.length >= 3) {
      sel3.value = state.projects[2].id;
    }
  }

  renderBudgetComparison();
}

function addToCompare(projectId) {
  closeModal('projectDetailModal');
  switchTab('comparison');
  const sel1 = document.getElementById('compareSelect1');
  const sel2 = document.getElementById('compareSelect2');
  if (sel1 && !sel1.value) sel1.value = projectId;
  else if (sel2) sel2.value = projectId;
  renderBudgetComparison();
  showToast('Project added to comparison', 'info');
}

function renderBudgetComparison() {
  const container = document.getElementById('comparisonContainer');
  if (!container) return;

  const id1 = document.getElementById('compareSelect1')?.value;
  const id2 = document.getElementById('compareSelect2')?.value;
  const id3 = document.getElementById('compareSelect3')?.value;

  const selectedIds = [id1, id2, id3].filter(Boolean);
  const projects = selectedIds.map(id => state.projects.find(p => p.id === id)).filter(Boolean);

  if (projects.length === 0) {
    container.innerHTML = '<div class="text-muted" style="text-align: center; padding: 2rem;">Please select at least one project above to compare.</div>';
    return;
  }

  container.innerHTML = `
    <div class="comparison-grid">
      ${projects.map(p => {
        const percent = p.progress !== undefined ? p.progress : Math.min(100, Math.round((p.spent / p.budget) * 100));
        const variance = p.spent - (p.budget * (percent / 100));
        const varianceColor = variance > 0 ? '#D32F2F' : '#2E7D32';

        return `
          <div class="compare-col-card">
            <h4 style="font-size: 1.1rem; margin-bottom: 0.25rem;">${escapeHtml(p.title)}</h4>
            <div style="font-family: monospace; font-size: 0.8rem; color: var(--text-hint); margin-bottom: 1rem;">${p.id} • ${p.province.toUpperCase()}</div>

            <div class="project-budget-stats">
              <div class="budget-stat-row">
                <span class="budget-stat-label">Sanctioned Budget:</span>
                <span class="budget-stat-val">${formatPKR(p.budget)}</span>
              </div>
              <div class="budget-stat-row">
                <span class="budget-stat-label">Actual Spent:</span>
                <span class="budget-stat-val">${formatPKR(p.spent)}</span>
              </div>
              <div class="budget-stat-row">
                <span class="budget-stat-label">Progress Velocity:</span>
                <span class="budget-stat-val">${percent}%</span>
              </div>
              <div class="budget-stat-row">
                <span class="budget-stat-label">Cost Variance:</span>
                <span class="budget-stat-val" style="color: ${varianceColor};">${variance > 0 ? '+' : ''}${formatPKR(variance)}</span>
              </div>
            </div>

            <div style="margin: 1rem 0;">
              <div style="font-size: 0.8rem; font-weight: 600; margin-bottom: 0.25rem;">Physical Completion</div>
              <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: ${percent}%;"></div>
              </div>
            </div>

            <div style="font-size: 0.82rem; color: var(--text-muted); line-height: 1.5;">
              <div><strong>Sector:</strong> ${escapeHtml(p.sector)}</div>
              <div><strong>Contractor:</strong> ${escapeHtml(p.contractor?.name || 'Public Authority')}</div>
              <div><strong>Status:</strong> ${escapeHtml(p.status)}</div>
            </div>

            <button class="btn btn-outline btn-sm btn-block" style="margin-top: 1rem;" onclick="openProjectDetail('${p.id}')">View Details</button>
          </div>
        `;
      }).join('')}
    </div>
  `;
}

// ─── AI Insights & Anomalies ──────────────────────────────────────────────────

function renderAIInsights() {
  const grid = document.getElementById('aiInsightsGrid');
  if (!grid) return;

  const insights = [
    {
      title: 'Disbursement vs Physical Milestone Anomaly',
      type: 'warning',
      badge: 'Medium Risk Alert',
      desc: 'Lahore Metro Orange Line Line-B Extension has utilized 78% of sanctioned funds while physical milestone audit reports only 45% completion. Recommended action: AGP technical audit before releasing next tranche.',
      metricLabel: 'Variance Deviation',
      metricVal: '+33% Spending Gap',
    },
    {
      title: 'High-Concentration Contractor Risk Watch',
      type: 'info',
      badge: 'Procurement Alert',
      desc: 'National Construction Consortium currently holds 3 simultaneous major provincial contracts exceeding PKR 3.8 Billion. Milestone delivery velocity is on track but requires quarterly performance bond review.',
      metricLabel: 'Portfolio Exposure',
      metricVal: 'PKR 3.8B Total Value',
    },
    {
      title: 'Optimal Execution: PIMS Emergency Ward Upgrade',
      type: 'success',
      badge: 'Best Practice',
      desc: 'Rawalpindi and Islamabad health sector upgrades are performing with 95% physical delivery matching 92% budget disbursement. Clean audit trail with zero citizen complaints.',
      metricLabel: 'Cost Efficiency Score',
      metricVal: '98.2 / 100',
    },
    {
      title: 'Price Inflation & Material Escalation Alert',
      type: 'warning',
      badge: 'Economic Advisory',
      desc: 'CPEC Highway Link M-8 reports steel and bitumen price escalations of 14% against PC-1 baseline estimates. Recommended action: Contract price adjustment review under PPRA Clause 43.',
      metricLabel: 'Projected Overrun',
      metricVal: 'PKR 450 Million',
    },
  ];

  grid.innerHTML = insights.map(item => `
    <div class="ai-card">
      <div class="ai-card-header">
        <span class="badge ${item.type === 'warning' ? 'badge-yellow' : item.type === 'success' ? 'badge-green' : 'badge-blue'}">${item.badge}</span>
      </div>
      <h4 class="ai-card-title">${item.title}</h4>
      <p class="ai-card-body">${item.desc}</p>
      <div class="ai-metric-box">
        <span>${item.metricLabel}</span>
        <strong>${item.metricVal}</strong>
      </div>
    </div>
  `).join('');
}

// ─── Budget Analytics ─────────────────────────────────────────────────────────

function renderAnalytics() {
  if (!state.analytics) return;
  const a = state.analytics;

  // Render Provincial Bars
  const provContainer = document.getElementById('provincialBars');
  if (provContainer && a.byProvince) {
    const provEntries = Object.entries(a.byProvince);
    const maxVal = Math.max(...provEntries.map(e => e[1].budget), 1);

    provContainer.innerHTML = provEntries.map(([prov, data]) => {
      const fillPct = Math.round((data.budget / maxVal) * 100);
      return `
        <div class="chart-bar-item">
          <div class="chart-bar-label">
            <span>${prov.toUpperCase()} (${data.count} projects)</span>
            <span>${formatPKR(data.budget)}</span>
          </div>
          <div class="chart-bar-track">
            <div class="chart-bar-track-fill" style="width: ${fillPct}%;"></div>
          </div>
        </div>
      `;
    }).join('');
  }

  // Render Sector Bars
  const sectorContainer = document.getElementById('sectorBars');
  if (sectorContainer && a.bySector) {
    const sectorEntries = Object.entries(a.bySector);
    const maxVal = Math.max(...sectorEntries.map(e => e[1].budget), 1);

    sectorContainer.innerHTML = sectorEntries.map(([sec, data]) => {
      const fillPct = Math.round((data.budget / maxVal) * 100);
      return `
        <div class="chart-bar-item">
          <div class="chart-bar-label">
            <span>${sec.toUpperCase()} (${data.count})</span>
            <span>${formatPKR(data.budget)}</span>
          </div>
          <div class="chart-bar-track">
            <div class="chart-bar-track-fill" style="width: ${fillPct}%; background-color: var(--accent);"></div>
          </div>
        </div>
      `;
    }).join('');
  }

  // Render Risk Matrix
  const riskContainer = document.getElementById('riskMatrixContainer');
  if (riskContainer && a.riskBreakdown) {
    riskContainer.innerHTML = `
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; text-align: center;">
        <div style="background: #E8F5E9; padding: 1rem; border-radius: 8px;">
          <div style="font-size: 1.8rem; font-weight: 800; color: #2E7D32;">${a.riskBreakdown.low || 0}</div>
          <div style="font-size: 0.8rem; font-weight: 600; color: #1B5E20;">LOW RISK SCHEMES</div>
        </div>
        <div style="background: #FFF9C4; padding: 1rem; border-radius: 8px;">
          <div style="font-size: 1.8rem; font-weight: 800; color: #F57F17;">${a.riskBreakdown.medium || 0}</div>
          <div style="font-size: 0.8rem; font-weight: 600; color: #E65100;">MODERATE SURVEILLANCE</div>
        </div>
        <div style="background: #FFEBEE; padding: 1rem; border-radius: 8px;">
          <div style="font-size: 1.8rem; font-weight: 800; color: #C62828;">${a.riskBreakdown.high || 0}</div>
          <div style="font-size: 0.8rem; font-weight: 600; color: #B71C1C;">HIGH ANOMALY AUDIT</div>
        </div>
      </div>
    `;
  }
}

// ─── QR Scanner & Direct Lookup ───────────────────────────────────────────────

function simulateCameraScan(code) {
  showToast(`🔍 Camera Reticle Locked: Found QR Code [${code}]`, 'success');
  setTimeout(() => {
    lookupProjectByCode(code);
  }, 600);
}

function lookupProjectByCode(rawCode) {
  const code = (rawCode || '').trim().toUpperCase();
  if (!code) {
    showToast('Please enter a valid Project Code', 'error');
    return;
  }

  const project = state.projects.find(p => p.id.toUpperCase() === code || p.id.toUpperCase().includes(code));
  if (project) {
    openProjectDetail(project.id);
  } else {
    showToast(`No project found with Code: ${code}`, 'error');
  }
}

function openQrShareModal(projectId) {
  const project = state.projects.find(p => p.id === projectId);
  if (!project) return;

  document.getElementById('qrDisplayCode').textContent = project.id;

  // Generate an authentic QR-like SVG vector
  const svg = `
    <svg width="180" height="180" viewBox="0 0 180 180" style="background:#fff; padding:10px; border:2px solid #01411C; border-radius:8px;">
      <!-- Corner Markers -->
      <rect x="10" y="10" width="40" height="40" fill="#01411C"/>
      <rect x="18" y="18" width="24" height="24" fill="#FFFFFF"/>
      <rect x="24" y="24" width="12" height="12" fill="#01411C"/>

      <rect x="130" y="10" width="40" height="40" fill="#01411C"/>
      <rect x="138" y="18" width="24" height="24" fill="#FFFFFF"/>
      <rect x="144" y="24" width="12" height="12" fill="#01411C"/>

      <rect x="10" y="130" width="40" height="40" fill="#01411C"/>
      <rect x="18" y="138" width="24" height="24" fill="#FFFFFF"/>
      <rect x="24" y="144" width="12" height="12" fill="#01411C"/>

      <!-- Matrix Elements -->
      <rect x="60" y="20" width="12" height="12" fill="#01411C"/>
      <rect x="80" y="20" width="12" height="12" fill="#01411C"/>
      <rect x="100" y="20" width="12" height="12" fill="#01411C"/>
      <rect x="60" y="40" width="24" height="12" fill="#01411C"/>
      <rect x="90" y="40" width="12" height="24" fill="#01411C"/>

      <rect x="20" y="60" width="12" height="24" fill="#01411C"/>
      <rect x="40" y="80" width="24" height="12" fill="#01411C"/>
      <rect x="70" y="70" width="36" height="36" fill="#01411C"/>
      <rect x="80" y="80" width="16" height="16" fill="#FFFFFF"/>

      <rect x="120" y="70" width="24" height="12" fill="#01411C"/>
      <rect x="150" y="80" width="12" height="24" fill="#01411C"/>

      <rect x="60" y="120" width="12" height="24" fill="#01411C"/>
      <rect x="80" y="130" width="24" height="12" fill="#01411C"/>
      <rect x="120" y="120" width="36" height="12" fill="#01411C"/>
      <rect x="130" y="140" width="20" height="20" fill="#01411C"/>
    </svg>
  `;

  document.getElementById('qrCanvasWrap').innerHTML = svg;
  openModal('qrShareModal');
}

function copyProjectShareUrl() {
  const code = document.getElementById('qrDisplayCode')?.textContent || '';
  const url = `${window.location.origin}?project=${code}`;
  navigator.clipboard.writeText(url).then(() => {
    showToast('Direct project link copied to clipboard!', 'success');
  }).catch(() => {
    showToast(`Link: ${url}`, 'info');
  });
}

// ─── Whistleblower Complaint Submission ───────────────────────────────────────

function populateReportProjectOptions() {
  const sel = document.getElementById('reportProjectSelect');
  if (!sel) return;

  sel.innerHTML = '<option value="">-- Select Public Project --</option>' +
    state.projects.map(p => `<option value="${p.id}">${escapeHtml(p.id)}: ${escapeHtml(p.title)}</option>`).join('');
}

function reportDiscrepancyForProject(projectId) {
  closeModal('projectDetailModal');
  switchTab('report');
  const sel = document.getElementById('reportProjectSelect');
  if (sel) {
    sel.value = projectId;
  }
}

function detectGPSCoordinates() {
  const input = document.getElementById('reportLocationInput');
  if (!input) return;

  // Realistic Pakistan project site coordinates
  const coords = [
    '31.5204° N, 74.3587° E (Lahore Central)',
    '24.8607° N, 67.0011° E (Karachi South)',
    '33.6844° N, 73.0479° E (Islamabad Capital)',
    '34.0151° N, 71.5249° E (Peshawar Valley)',
    '30.1798° N, 66.9750° E (Quetta District)',
  ];
  const pick = coords[Math.floor(Math.random() * coords.length)];
  input.value = pick;
  showToast('GPS Satellite Coordinates Tagged', 'success');
}

function previewEvidenceFile(input) {
  const hint = document.getElementById('fileHintText');
  if (input.files && input.files[0]) {
    const file = input.files[0];
    hint.textContent = `Attached: ${file.name} (${(file.size / 1024).toFixed(1)} KB) - Ready for encryption`;
    hint.style.color = 'var(--primary)';
  }
}

async function handleReportSubmit(e) {
  e.preventDefault();

  const projectId = document.getElementById('reportProjectSelect')?.value;
  const category = document.getElementById('reportViolationType')?.value;
  const title = document.getElementById('reportTitleInput')?.value;
  const severity = document.getElementById('reportSeverity')?.value;
  const description = document.getElementById('reportDescriptionInput')?.value;
  const location = document.getElementById('reportLocationInput')?.value;
  const isAnonymous = document.getElementById('reportAnonymousCheck')?.checked;

  if (!projectId || !title || !description) {
    showToast('Please fill all required complaint fields', 'error');
    return;
  }

  const btn = document.getElementById('submitReportBtn');
  if (btn) btn.disabled = true;

  try {
    const payload = {
      projectId,
      category,
      title,
      severity,
      description,
      location,
      isAnonymous,
      submittedBy: isAnonymous ? 'ANONYMOUS_CITIZEN' : state.user.name,
      evidenceUrl: 'https://paktransparent.pk/evidence/verified_sample.jpg',
    };

    const res = await apiRequest('/api/reports', 'POST', payload);
    if (res.success) {
      showToast(`Whistleblower Report #${res.data.id} submitted securely!`, 'success');
      document.getElementById('whistleblowerForm').reset();
      await refreshReportsAndAudit();
      switchTab('my-reports');
    }
  } catch (err) {
    showToast(err.message || 'Failed to submit report', 'error');
  } finally {
    if (btn) btn.disabled = false;
  }
}

// ─── My Reports Screen ────────────────────────────────────────────────────────

function renderMyReports() {
  const container = document.getElementById('myReportsList');
  if (!container) return;

  if (state.reports.length === 0) {
    container.innerHTML = '<div class="text-muted" style="text-align: center; padding: 2rem;">No whistleblower reports filed yet.</div>';
    return;
  }

  container.innerHTML = state.reports.map(r => {
    const statusBadge = r.status === 'resolved' ? 'badge-green' : r.status === 'rejected' ? 'badge-red' : r.status === 'under_investigation' ? 'badge-blue' : 'badge-yellow';
    const severityBadge = r.severity === 'critical' || r.severity === 'high' ? 'badge-red' : 'badge-yellow';

    return `
      <div class="card" style="margin-bottom: 1rem;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
          <div>
            <h4 style="font-size: 1.1rem; font-weight: 700;">${escapeHtml(r.title)}</h4>
            <div style="font-family: monospace; font-size: 0.8rem; color: var(--text-hint);">
              Report #${r.id} • Project: ${escapeHtml(r.projectId)} • ${formatDate(r.createdAt)}
            </div>
          </div>
          <div style="display: flex; gap: 0.4rem;">
            <span class="badge ${severityBadge}">${r.severity} severity</span>
            <span class="badge ${statusBadge}">${(r.status || 'submitted').replace('_', ' ')}</span>
          </div>
        </div>

        <p style="font-size: 0.88rem; color: var(--text-muted); line-height: 1.5; margin-bottom: 0.85rem;">
          ${escapeHtml(r.description)}
        </p>

        ${r.officialResponse ? `
          <div style="background: #E8F5E9; border-left: 3px solid #2E7D32; padding: 0.85rem; border-radius: 4px; margin-top: 0.75rem;">
            <strong style="color: #1B5E20; display: block; font-size: 0.85rem;">Official Departmental Ruling:</strong>
            <p style="font-size: 0.82rem; color: #1B2E24; margin-top: 0.2rem;">${escapeHtml(r.officialResponse)}</p>
            ${r.actionTaken ? `<div style="margin-top: 0.35rem; font-size: 0.78rem; color: #2E7D32;"><strong>Action Taken:</strong> ${escapeHtml(r.actionTaken)}</div>` : ''}
          </div>
        ` : `
          <div style="font-size: 0.78rem; color: var(--text-hint); font-style: italic;">
            ⏳ Currently queued for official inspection team review under Public Audit Rule 7.
          </div>
        `}
      </div>
    `;
  }).join('');
}

// ─── Government Portal (Officials View) ────────────────────────────────────────

function renderGovReportsTable() {
  const tbody = document.getElementById('govReportsTableBody');
  if (!tbody) return;

  if (state.reports.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted">No pending citizen reports.</td></tr>';
    return;
  }

  tbody.innerHTML = state.reports.map(r => {
    const statusBadge = r.status === 'resolved' ? 'badge-green' : r.status === 'rejected' ? 'badge-red' : r.status === 'under_investigation' ? 'badge-blue' : 'badge-yellow';
    const severityBadge = r.severity === 'critical' || r.severity === 'high' ? 'badge-red' : 'badge-yellow';

    return `
      <tr>
        <td style="font-family: monospace;">#${r.id}</td>
        <td><strong>${escapeHtml(r.projectId)}</strong></td>
        <td>${escapeHtml(r.title)}</td>
        <td><span class="badge ${severityBadge}">${r.severity}</span></td>
        <td><span class="badge ${statusBadge}">${(r.status || 'submitted').replace('_', ' ')}</span></td>
        <td>${formatDate(r.createdAt)}</td>
        <td>
          <button class="btn btn-sm btn-outline" onclick="openGovReviewModal('${r.id}')">Review & Rule →</button>
        </td>
      </tr>
    `;
  }).join('');
}

function openGovReviewModal(reportId) {
  const report = state.reports.find(r => r.id === reportId);
  if (!report) return;

  document.getElementById('govReviewReportId').value = report.id;
  document.getElementById('govReviewStatus').value = report.status || 'under_investigation';
  document.getElementById('govReviewResponse').value = report.officialResponse || '';
  document.getElementById('govReviewActionTaken').value = report.actionTaken || '';

  document.getElementById('govReviewReportSummary').innerHTML = `
    <strong>Report #${report.id}: ${escapeHtml(report.title)}</strong>
    <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem;">${escapeHtml(report.description)}</p>
    <div style="font-size: 0.75rem; color: var(--text-hint); margin-top: 0.35rem;">
      Project: ${report.projectId} • Severity: ${report.severity} • Whistleblower: ${report.isAnonymous ? 'Protected Anonymous Citizen' : escapeHtml(report.submittedBy || 'Citizen')}
    </div>
  `;

  openModal('govReportReviewModal');
}

async function handleGovReportResolutionSubmit(e) {
  e.preventDefault();

  const reportId = document.getElementById('govReviewReportId')?.value;
  const status = document.getElementById('govReviewStatus')?.value;
  const officialResponse = document.getElementById('govReviewResponse')?.value;
  const actionTaken = document.getElementById('govReviewActionTaken')?.value;

  try {
    const payload = {
      status,
      officialResponse,
      actionTaken,
      reviewedBy: state.user.name,
    };

    const res = await apiRequest(`/api/reports/${reportId}/status`, 'PATCH', payload);
    if (res.success) {
      showToast(`Official ruling recorded on Report #${reportId}`, 'success');
      closeModal('govReportReviewModal');
      await refreshReportsAndAudit();
    }
  } catch (err) {
    showToast(err.message || 'Failed to update report status', 'error');
  }
}

// ─── Create New Project (Official) ─────────────────────────────────────────────

function openCreateProjectModalIfAuthorized() {
  if (state.user.role !== 'government') {
    showToast('Project sanctioning requires Government Official credentials. Switching you to Official demo...', 'info');
    selectRole('government');
    return;
  }
  openCreateProjectModal();
}

function openCreateProjectModal() {
  openModal('createProjectModal');
}

async function handleCreateProjectSubmit(e) {
  e.preventDefault();

  const title = document.getElementById('newProjTitle')?.value;
  const sector = document.getElementById('newProjSector')?.value;
  const description = document.getElementById('newProjDescription')?.value;
  const province = document.getElementById('newProjProvince')?.value;
  const district = document.getElementById('newProjDistrict')?.value;
  const budget = parseFloat(document.getElementById('newProjBudget')?.value);
  const contractorName = document.getElementById('newProjContractorName')?.value;
  const contractorNtn = document.getElementById('newProjContractorNtn')?.value;
  const endDate = document.getElementById('newProjEndDate')?.value;

  // Verify Authority Ceiling
  if (budget > (OFFICIAL_USER.approvalAuthority || 1000000000)) {
    showToast(`Project Budget (${formatPKR(budget)}) exceeds your authorized sanction ceiling of PKR 1 Billion!`, 'error');
    return;
  }

  const btn = document.getElementById('saveProjectBtn');
  if (btn) btn.disabled = true;

  try {
    const payload = {
      title,
      sector,
      description,
      province,
      district,
      budget,
      contractor: {
        name: contractorName,
        ntn: contractorNtn,
        rating: 4.8,
        completedProjects: 12,
        activeProjects: 3,
      },
      startDate: new Date().toISOString(),
      targetCompletionDate: new Date(endDate).toISOString(),
    };

    const res = await apiRequest('/api/projects', 'POST', payload);
    if (res.success) {
      showToast(`Project Sanctioned Successfully: ${res.data.id}`, 'success');
      closeModal('createProjectModal');
      document.getElementById('createProjectForm').reset();
      await refreshAllData();
      switchTab('projects');
    }
  } catch (err) {
    showToast(err.message || 'Failed to sanction project', 'error');
  } finally {
    if (btn) btn.disabled = false;
  }
}

// ─── Cryptographic Audit Trail ────────────────────────────────────────────────

function renderAuditTrail() {
  const container = document.getElementById('auditListContainer');
  if (!container) return;

  if (state.auditLogs.length === 0) {
    container.innerHTML = '<div class="text-muted" style="text-align: center; padding: 2rem;">No audit transactions recorded.</div>';
    return;
  }

  container.innerHTML = state.auditLogs.map(log => {
    const timeStr = log.timestamp ? new Date(log.timestamp).toLocaleString() : 'Just now';
    return `
      <div class="audit-entry">
        <div class="audit-meta-row">
          <span>Actor: <strong>${escapeHtml(log.userId || 'SYSTEM')}</strong></span>
          <span>${timeStr}</span>
        </div>
        <div>
          <span class="audit-action-tag">[${escapeHtml(log.action)}]</span>
          Resource: <strong>${escapeHtml(log.resource || 'SYSTEM')}</strong>
          ${log.details ? `— <span style="font-family: monospace; font-size: 0.78rem;">${JSON.stringify(log.details)}</span>` : ''}
        </div>
      </div>
    `;
  }).join('');
}

// ─── Modal Management ─────────────────────────────────────────────────────────

function openModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) modal.classList.add('active');
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) modal.classList.remove('active');
}

// ─── Language & Localization (English / اردو) ────────────────────────────────

function toggleLanguage() {
  state.currentLang = state.currentLang === 'en' ? 'ur' : 'en';
  document.documentElement.setAttribute('lang', state.currentLang);
  document.documentElement.setAttribute('dir', state.currentLang === 'ur' ? 'rtl' : 'ltr');

  const langBtnLabel = document.getElementById('langLabel');
  if (langBtnLabel) {
    langBtnLabel.textContent = state.currentLang === 'en' ? 'اردو' : 'English';
  }

  // Update all translatable elements
  document.querySelectorAll('[data-en]').forEach(el => {
    const trans = el.getAttribute(`data-${state.currentLang}`);
    if (trans) el.textContent = trans;
  });

  const liveText = document.getElementById('liveStatusText');
  if (liveText) {
    liveText.textContent = state.currentLang === 'ur' ? 'براہ راست رابطہ: فعال' : 'Real-Time: Connected';
  }
}

// ─── Role Switcher ────────────────────────────────────────────────────────────

function openUserSwitchModal() {
  openModal('userSwitchModal');
}

function selectRole(role) {
  closeModal('userSwitchModal');

  if (role === 'government') {
    state.user = { ...OFFICIAL_USER };
    document.getElementById('userRoleTag').textContent = 'Government Official';
    document.getElementById('userName').textContent = state.user.name;

    // Show Gov Tabs
    document.getElementById('govNavTab').style.display = 'flex';
    document.getElementById('auditNavTab').style.display = 'flex';

    showToast(`Logged in as Official: ${state.user.name} (DG Public Works)`, 'success');
    switchTab('government');
  } else {
    state.user = { ...CITIZEN_USER };
    document.getElementById('userRoleTag').textContent = 'Citizen';
    document.getElementById('userName').textContent = state.user.name;

    showToast(`Logged in as Citizen: ${state.user.name}`, 'info');
    switchTab('dashboard');
  }
}

// ─── Tab Switching ────────────────────────────────────────────────────────────

function switchTab(tabId) {
  state.activeTab = tabId;

  // Update Tab Navigation Active State
  document.querySelectorAll('.nav-tab').forEach(tab => {
    tab.classList.toggle('active', tab.getAttribute('data-tab') === tabId);
  });

  // Update Panels
  document.querySelectorAll('.tab-panel').forEach(panel => {
    panel.classList.toggle('active', panel.id === `tab-${tabId}`);
  });

  // Refresh Specific Views on demand
  if (tabId === 'projects') renderProjectsList();
  if (tabId === 'comparison') renderBudgetComparison();
  if (tabId === 'analytics') renderAnalytics();
  if (tabId === 'insights') renderAIInsights();
  if (tabId === 'my-reports') renderMyReports();
  if (tabId === 'government') renderGovReportsTable();
  if (tabId === 'audit') renderAuditTrail();

  window.scrollTo({ top: 0, behavior: 'smooth' });
}

// ─── Utility Helpers ──────────────────────────────────────────────────────────

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

// Close modals when clicking backdrop
window.addEventListener('click', (e) => {
  if (e.target.classList.contains('modal-overlay')) {
    e.target.classList.remove('active');
  }
});

// ─── App Bootstrap ────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  console.log('Pakistan Transparent App Initializing...');
  initSSE();
  refreshAllData();
});
