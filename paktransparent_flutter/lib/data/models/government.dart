// Government hierarchy and role types
// Ported from api/types/government.ts

enum GovernmentRole {
  prime_minister,
  chief_minister,
  governor,
  federal_minister,
  provincial_minister,
  chief_secretary,
  commissioner,
  deputy_commissioner,
  assistant_commissioner,
  tehsildar,
  department_head,
  section_officer,
  other,
}

class GovernmentHierarchyInfo {
  final GovernmentRole role;
  final int level; // 1 = highest (PM)
  final String title;
  final double canApproveUpTo;
  final bool canCreateProjects;
  final bool canApproveProjects;
  final bool canAssignTasks;
  final bool canEscalate;
  final GovernmentRole? reportsTo;
  final bool canViewNational;
  final bool canViewProvincial;
  final bool canViewDistrict;

  const GovernmentHierarchyInfo({
    required this.role,
    required this.level,
    required this.title,
    required this.canApproveUpTo,
    required this.canCreateProjects,
    required this.canApproveProjects,
    required this.canAssignTasks,
    required this.canEscalate,
    required this.canViewNational,
    required this.canViewProvincial,
    required this.canViewDistrict,
    this.reportsTo,
  });
}

class RoleInfo {
  final String title;
  final String office;
  final String description;

  const RoleInfo({
    required this.title,
    required this.office,
    required this.description,
  });
}

/// Government hierarchy — ported from GOVERNMENT_HIERARCHY constant.
const Map<GovernmentRole, GovernmentHierarchyInfo> governmentHierarchy = {
  GovernmentRole.prime_minister: GovernmentHierarchyInfo(
    role: GovernmentRole.prime_minister,
    level: 1,
    title: 'Prime Minister of Pakistan',
    canApproveUpTo: double.infinity,
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: false,
    canViewNational: true,
    canViewProvincial: true,
    canViewDistrict: true,
  ),
  GovernmentRole.chief_minister: GovernmentHierarchyInfo(
    role: GovernmentRole.chief_minister,
    level: 2,
    title: 'Chief Minister',
    canApproveUpTo: 50000000000,
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: true,
    reportsTo: GovernmentRole.prime_minister,
    canViewNational: false,
    canViewProvincial: true,
    canViewDistrict: true,
  ),
  GovernmentRole.deputy_commissioner: GovernmentHierarchyInfo(
    role: GovernmentRole.deputy_commissioner,
    level: 4,
    title: 'Deputy Commissioner',
    canApproveUpTo: 2000000000,
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: true,
    reportsTo: GovernmentRole.commissioner,
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  ),
  GovernmentRole.department_head: GovernmentHierarchyInfo(
    role: GovernmentRole.department_head,
    level: 4,
    title: 'Department Head',
    canApproveUpTo: 1000000000,
    canCreateProjects: true,
    canApproveProjects: true,
    canAssignTasks: true,
    canEscalate: true,
    reportsTo: GovernmentRole.chief_secretary,
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  ),
  GovernmentRole.section_officer: GovernmentHierarchyInfo(
    role: GovernmentRole.section_officer,
    level: 5,
    title: 'Section Officer',
    canApproveUpTo: 100000000,
    canCreateProjects: false,
    canApproveProjects: false,
    canAssignTasks: false,
    canEscalate: true,
    reportsTo: GovernmentRole.department_head,
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  ),
  GovernmentRole.other: GovernmentHierarchyInfo(
    role: GovernmentRole.other,
    level: 5,
    title: 'Government Official',
    canApproveUpTo: 0,
    canCreateProjects: false,
    canApproveProjects: false,
    canAssignTasks: false,
    canEscalate: true,
    canViewNational: false,
    canViewProvincial: false,
    canViewDistrict: true,
  ),
};

/// Role display info — ported from ROLE_INFO constant.
const Map<GovernmentRole, RoleInfo> roleInfo = {
  GovernmentRole.prime_minister: RoleInfo(
    title: 'Prime Minister',
    office: 'Office of the Prime Minister',
    description: 'Highest executive authority of Pakistan',
  ),
  GovernmentRole.chief_minister: RoleInfo(
    title: 'Chief Minister',
    office: 'Chief Minister Office',
    description: 'Head of provincial government',
  ),
  GovernmentRole.governor: RoleInfo(
    title: 'Governor',
    office: 'Governor House',
    description: 'Constitutional head of province',
  ),
  GovernmentRole.federal_minister: RoleInfo(
    title: 'Federal Minister',
    office: 'Federal Ministry',
    description: 'Federal cabinet member',
  ),
  GovernmentRole.provincial_minister: RoleInfo(
    title: 'Provincial Minister',
    office: 'Provincial Ministry',
    description: 'Provincial cabinet member',
  ),
  GovernmentRole.chief_secretary: RoleInfo(
    title: 'Chief Secretary',
    office: 'Provincial Secretariat',
    description: 'Administrative head of province',
  ),
  GovernmentRole.commissioner: RoleInfo(
    title: 'Commissioner',
    office: 'Commissioner Office',
    description: 'Divisional coordinator',
  ),
  GovernmentRole.deputy_commissioner: RoleInfo(
    title: 'Deputy Commissioner',
    office: 'DC Office',
    description: 'District administrative head',
  ),
  GovernmentRole.assistant_commissioner: RoleInfo(
    title: 'Assistant Commissioner',
    office: 'AC Office',
    description: 'Tehsil administrative officer',
  ),
  GovernmentRole.tehsildar: RoleInfo(
    title: 'Tehsildar',
    office: 'Tehsil Office',
    description: 'Revenue officer',
  ),
  GovernmentRole.department_head: RoleInfo(
    title: 'Department Head',
    office: 'Department Office',
    description: 'Head of government department',
  ),
  GovernmentRole.section_officer: RoleInfo(
    title: 'Section Officer',
    office: 'Section Office',
    description: 'Section administrative officer',
  ),
  GovernmentRole.other: RoleInfo(
    title: 'Government Official',
    office: 'Government Office',
    description: 'Other government role',
  ),
};

/// Determine required approval level based on budget amount.
int getRequiredApprovalLevel(double budget) {
  if (budget >= 50000000000) return 1; // PM level
  if (budget >= 10000000000) return 2; // CM level
  if (budget >= 2000000000) return 3; // Secretary level
  if (budget >= 500000000) return 4; // Deputy level
  return 5; // Section officer level
}

/// Check if a government user can approve a project with the given budget.
({bool canApprove, String? reason, GovernmentRole? escalateTo})
    canUserApproveProject(GovernmentRole role, double budget) {
  final hierarchy = governmentHierarchy[role];

  if (hierarchy == null) {
    return (canApprove: false, reason: 'Role hierarchy not found', escalateTo: null);
  }

  if (!hierarchy.canApproveProjects) {
    return (
      canApprove: false,
      reason: 'Your role does not have project approval authority',
      escalateTo: hierarchy.reportsTo,
    );
  }

  if (budget > hierarchy.canApproveUpTo) {
    return (
      canApprove: false,
      reason: 'Budget exceeds your approval limit',
      escalateTo: hierarchy.reportsTo,
    );
  }

  return (canApprove: true, reason: null, escalateTo: null);
}
