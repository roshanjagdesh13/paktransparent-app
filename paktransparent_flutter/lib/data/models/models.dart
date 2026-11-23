import 'government.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum UserRole { citizen, government, admin, contractor }

enum ProjectStatus {
  pending,
  approved,
  inProgress,
  completed,
  suspended,
  cancelled,
  requiresApproval,
}

enum ReportStatus { submitted, underReview, resolved, rejected }

enum Province {
  punjab,
  sindh,
  kpk,
  balochistan,
  gilgitBaltistan,
  azadKashmir,
}

enum ProjectCategory {
  infrastructure,
  education,
  healthcare,
  transport,
  energy,
  water,
  agriculture,
  defense,
  socialWelfare,
  other,
}

// ─── User Model ───────────────────────────────────────────────────────────────

class User {
  final String id;
  final String email;
  final String? cnic;
  final String name;
  final UserRole role;
  final GovernmentRole? governmentRole;
  final String? employeeCode;
  final String? designation;
  final double? approvalAuthority;
  final String? avatar;
  final String? phone;
  final Province? province;
  final String? district;
  final String? department;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    this.cnic,
    this.governmentRole,
    this.employeeCode,
    this.designation,
    this.approvalAuthority,
    this.avatar,
    this.phone,
    this.province,
    this.district,
    this.department,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.citizen,
      ),
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      cnic: json['cnic'] as String?,
      employeeCode: json['employeeCode'] as String?,
      designation: json['designation'] as String?,
      approvalAuthority: (json['approvalAuthority'] as num?)?.toDouble(),
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      district: json['district'] as String?,
      department: json['department'] as String?,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'] as String)
          : null,
      governmentRole: json['governmentRole'] != null
          ? GovernmentRole.values.firstWhere(
              (e) => e.name == json['governmentRole'],
              orElse: () => GovernmentRole.other,
            )
          : null,
      province: json['province'] != null
          ? Province.values.firstWhere(
              (e) => e.name == (json['province'] as String).replaceAll('_', ''),
              orElse: () => Province.punjab,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
        'isVerified': isVerified,
        'createdAt': createdAt.toIso8601String(),
        'cnic': cnic,
        'employeeCode': employeeCode,
        'designation': designation,
        'approvalAuthority': approvalAuthority,
        'avatar': avatar,
        'phone': phone,
        'district': district,
        'department': department,
        'lastLogin': lastLogin?.toIso8601String(),
        'governmentRole': governmentRole?.name,
        'province': province?.name,
      };

  User copyWith({
    String? id,
    String? email,
    String? cnic,
    String? name,
    UserRole? role,
    GovernmentRole? governmentRole,
    String? employeeCode,
    String? designation,
    double? approvalAuthority,
    String? avatar,
    String? phone,
    Province? province,
    String? district,
    String? department,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      cnic: cnic ?? this.cnic,
      name: name ?? this.name,
      role: role ?? this.role,
      governmentRole: governmentRole ?? this.governmentRole,
      employeeCode: employeeCode ?? this.employeeCode,
      designation: designation ?? this.designation,
      approvalAuthority: approvalAuthority ?? this.approvalAuthority,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      district: district ?? this.district,
      department: department ?? this.department,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

// ─── Project Model ────────────────────────────────────────────────────────────

class ProjectLocation {
  final double lat;
  final double lng;
  final String address;

  const ProjectLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory ProjectLocation.fromJson(Map<String, dynamic> json) => ProjectLocation(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        address: json['address'] as String,
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };
}

class ProjectContractor {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;

  const ProjectContractor({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
  });

  factory ProjectContractor.fromJson(Map<String, dynamic> json) =>
      ProjectContractor(
        id: json['id'] as String,
        name: json['name'] as String,
        contactPerson: json['contactPerson'] as String,
        phone: json['phone'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contactPerson': contactPerson,
        'phone': phone,
      };
}

class Milestone {
  final String id;
  final String title;
  final String? description;
  final String status; // 'completed' | 'in_progress' | 'pending'
  final DateTime targetDate;
  final DateTime? completedDate;
  final int order;

  const Milestone({
    required this.id,
    required this.title,
    required this.status,
    required this.targetDate,
    required this.order,
    this.description,
    this.completedDate,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        status: json['status'] as String,
        targetDate: DateTime.parse(json['targetDate'] as String),
        completedDate: json['completedDate'] != null
            ? DateTime.tryParse(json['completedDate'] as String)
            : null,
        order: json['order'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'targetDate': targetDate.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'order': order,
      };
}

class ProjectDocument {
  final String id;
  final String name;
  final String type;
  final String url;
  final int size;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String category;
  final bool isPublic;

  const ProjectDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.size,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.category,
    required this.isPublic,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) => ProjectDocument(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        url: json['url'] as String,
        size: json['size'] as int,
        uploadedBy: json['uploadedBy'] as String,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        category: json['category'] as String,
        isPublic: json['isPublic'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'url': url,
        'size': size,
        'uploadedBy': uploadedBy,
        'uploadedAt': uploadedAt.toIso8601String(),
        'category': category,
        'isPublic': isPublic,
      };
}

class Project {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final ProjectCategory category;
  final ProjectStatus status;
  final Province province;
  final String district;
  final ProjectLocation location;
  final double budgetAllocated;
  final double budgetReleased;
  final double budgetSpent;
  final double budgetRemaining;
  final String currency;
  final DateTime startDate;
  final DateTime expectedEndDate;
  final DateTime? actualEndDate;
  final int completionPercentage;
  final String department;
  final ProjectContractor? contractor;
  final String? engineer;
  final String? consultant;
  final String? heroImage;
  final List<String> images;
  final List<String> videos;
  final List<ProjectDocument> documents;
  final List<Milestone> milestones;
  final int followers;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Project({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.province,
    required this.district,
    required this.location,
    required this.budgetAllocated,
    required this.budgetReleased,
    required this.budgetSpent,
    required this.budgetRemaining,
    required this.currency,
    required this.startDate,
    required this.expectedEndDate,
    required this.completionPercentage,
    required this.department,
    required this.images,
    required this.videos,
    required this.documents,
    required this.milestones,
    required this.followers,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.actualEndDate,
    this.contractor,
    this.engineer,
    this.consultant,
    this.heroImage,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ProjectCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String).replaceAll('_', ''),
        orElse: () => ProjectCategory.other,
      ),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String).replaceAll('_', ''),
        orElse: () => ProjectStatus.pending,
      ),
      province: Province.values.firstWhere(
        (e) => e.name == (json['province'] as String).replaceAll('_', ''),
        orElse: () => Province.punjab,
      ),
      district: json['district'] as String,
      location: ProjectLocation.fromJson(json['location'] as Map<String, dynamic>),
      budgetAllocated: (json['budgetAllocated'] as num).toDouble(),
      budgetReleased: (json['budgetReleased'] as num).toDouble(),
      budgetSpent: (json['budgetSpent'] as num).toDouble(),
      budgetRemaining: (json['budgetRemaining'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'PKR',
      startDate: DateTime.parse(json['startDate'] as String),
      expectedEndDate: DateTime.parse(json['expectedEndDate'] as String),
      actualEndDate: json['actualEndDate'] != null
          ? DateTime.tryParse(json['actualEndDate'] as String)
          : null,
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      department: json['department'] as String,
      contractor: json['contractor'] != null
          ? ProjectContractor.fromJson(json['contractor'] as Map<String, dynamic>)
          : null,
      engineer: json['engineer'] as String?,
      consultant: json['consultant'] as String?,
      heroImage: json['heroImage'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => ProjectDocument.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => Milestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      followers: json['followers'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'name': name,
        'description': description,
        'category': category.name,
        'status': status.name,
        'province': province.name,
        'district': district,
        'location': location.toJson(),
        'budgetAllocated': budgetAllocated,
        'budgetReleased': budgetReleased,
        'budgetSpent': budgetSpent,
        'budgetRemaining': budgetRemaining,
        'currency': currency,
        'startDate': startDate.toIso8601String(),
        'expectedEndDate': expectedEndDate.toIso8601String(),
        'actualEndDate': actualEndDate?.toIso8601String(),
        'completionPercentage': completionPercentage,
        'department': department,
        'contractor': contractor?.toJson(),
        'engineer': engineer,
        'consultant': consultant,
        'heroImage': heroImage,
        'images': images,
        'videos': videos,
        'documents': documents.map((d) => d.toJson()).toList(),
        'milestones': milestones.map((m) => m.toJson()).toList(),
        'followers': followers,
        'viewCount': viewCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'createdBy': createdBy,
      };
}

// ─── Citizen Report Model ─────────────────────────────────────────────────────

class ReportEvidence {
  final List<String> images;
  final List<String> videos;
  final List<String> documents;

  const ReportEvidence({
    required this.images,
    required this.videos,
    required this.documents,
  });

  factory ReportEvidence.fromJson(Map<String, dynamic> json) => ReportEvidence(
        images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
        videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? [],
        documents: (json['documents'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'images': images,
        'videos': videos,
        'documents': documents,
      };
}

class GovernmentResponse {
  final String respondedBy;
  final DateTime respondedAt;
  final String response;
  final String? actionTaken;

  const GovernmentResponse({
    required this.respondedBy,
    required this.respondedAt,
    required this.response,
    this.actionTaken,
  });

  factory GovernmentResponse.fromJson(Map<String, dynamic> json) =>
      GovernmentResponse(
        respondedBy: json['respondedBy'] as String,
        respondedAt: DateTime.parse(json['respondedAt'] as String),
        response: json['response'] as String,
        actionTaken: json['actionTaken'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'respondedBy': respondedBy,
        'respondedAt': respondedAt.toIso8601String(),
        'response': response,
        'actionTaken': actionTaken,
      };
}

class CitizenReport {
  final String id;
  final String projectId;
  final String citizenId;
  final String? citizenName;
  final String title;
  final String description;
  final String category;
  final ReportEvidence evidence;
  final double? locationLat;
  final double? locationLng;
  final ReportStatus status;
  final String priority;
  final bool isAnonymous;
  final GovernmentResponse? governmentResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CitizenReport({
    required this.id,
    required this.projectId,
    required this.citizenId,
    required this.title,
    required this.description,
    required this.category,
    required this.evidence,
    required this.status,
    required this.priority,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    this.citizenName,
    this.locationLat,
    this.locationLng,
    this.governmentResponse,
  });

  factory CitizenReport.fromJson(Map<String, dynamic> json) {
    return CitizenReport(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      citizenId: json['citizenId'] as String,
      citizenName: json['citizenName'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      evidence: ReportEvidence.fromJson(
          json['evidence'] as Map<String, dynamic>? ?? {}),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String).replaceAll('_', ''),
        orElse: () => ReportStatus.submitted,
      ),
      priority: json['priority'] as String? ?? 'medium',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      locationLat: (json['location']?['lat'] as num?)?.toDouble(),
      locationLng: (json['location']?['lng'] as num?)?.toDouble(),
      governmentResponse: json['governmentResponse'] != null
          ? GovernmentResponse.fromJson(
              json['governmentResponse'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'citizenId': citizenId,
        'citizenName': citizenName,
        'title': title,
        'description': description,
        'category': category,
        'evidence': evidence.toJson(),
        'status': status.name,
        'priority': priority,
        'isAnonymous': isAnonymous,
        if (locationLat != null && locationLng != null)
          'location': {'lat': locationLat, 'lng': locationLng},
        'governmentResponse': governmentResponse?.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ─── Budget Analytics Models ──────────────────────────────────────────────────

class BudgetOverview {
  final String fiscalYear;
  final double totalAllocated;
  final double totalSpent;
  final double totalRemaining;
  final double utilizationPercentage;
  final List<ProvinceBreakdown> byProvince;
  final List<CategoryBreakdown> byCategory;

  const BudgetOverview({
    required this.fiscalYear,
    required this.totalAllocated,
    required this.totalSpent,
    required this.totalRemaining,
    required this.utilizationPercentage,
    required this.byProvince,
    required this.byCategory,
  });

  factory BudgetOverview.fromJson(Map<String, dynamic> json) => BudgetOverview(
        fiscalYear: json['fiscalYear'] as String,
        totalAllocated: (json['totalAllocated'] as num).toDouble(),
        totalSpent: (json['totalSpent'] as num).toDouble(),
        totalRemaining: (json['totalRemaining'] as num).toDouble(),
        utilizationPercentage: (json['utilizationPercentage'] as num).toDouble(),
        byProvince: (json['byProvince'] as List<dynamic>?)
                ?.map((e) => ProvinceBreakdown.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        byCategory: (json['byCategory'] as List<dynamic>?)
                ?.map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class ProvinceBreakdown {
  final String province;
  final double allocated;
  final double spent;
  final int projectCount;
  final double utilizationRate;

  const ProvinceBreakdown({
    required this.province,
    required this.allocated,
    required this.spent,
    required this.projectCount,
    required this.utilizationRate,
  });

  factory ProvinceBreakdown.fromJson(Map<String, dynamic> json) =>
      ProvinceBreakdown(
        province: json['province'] as String,
        allocated: (json['allocated'] as num).toDouble(),
        spent: (json['spent'] as num).toDouble(),
        projectCount: json['projectCount'] as int,
        utilizationRate: (json['utilizationRate'] as num).toDouble(),
      );
}

class CategoryBreakdown {
  final String category;
  final double allocated;
  final double spent;
  final int projectCount;

  const CategoryBreakdown({
    required this.category,
    required this.allocated,
    required this.spent,
    required this.projectCount,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      CategoryBreakdown(
        category: json['category'] as String,
        allocated: (json['allocated'] as num).toDouble(),
        spent: (json['spent'] as num).toDouble(),
        projectCount: json['projectCount'] as int,
      );
}

// ─── Dashboard Stats ──────────────────────────────────────────────────────────

class DashboardStats {
  final int totalProjects;
  final int activeProjects;
  final int completedProjects;
  final double totalBudget;
  final double spentBudget;
  final int pendingReports;
  final int resolvedReports;
  final int citizenEngagement;

  const DashboardStats({
    required this.totalProjects,
    required this.activeProjects,
    required this.completedProjects,
    required this.totalBudget,
    required this.spentBudget,
    required this.pendingReports,
    required this.resolvedReports,
    required this.citizenEngagement,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalProjects: json['totalProjects'] as int? ?? 0,
        activeProjects: json['activeProjects'] as int? ?? 0,
        completedProjects: json['completedProjects'] as int? ?? 0,
        totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0,
        spentBudget: (json['spentBudget'] as num?)?.toDouble() ?? 0,
        pendingReports: json['pendingReports'] as int? ?? 0,
        resolvedReports: json['resolvedReports'] as int? ?? 0,
        citizenEngagement: json['citizenEngagement'] as int? ?? 0,
      );
}

// ─── API Response Wrappers ────────────────────────────────────────────────────

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  final DateTime timestamp;

  const ApiResponse({
    required this.success,
    required this.timestamp,
    this.data,
    this.error,
    this.message,
  });
}

class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? 20,
      total: pagination['total'] as int? ?? 0,
      totalPages: pagination['totalPages'] as int? ?? 0,
      hasNext: pagination['hasNext'] as bool? ?? false,
      hasPrevious: pagination['hasPrevious'] as bool? ?? false,
    );
  }

  static PaginatedResponse<T> empty<T>() => PaginatedResponse<T>(
        data: [],
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
        hasNext: false,
        hasPrevious: false,
      );
}

// ─── Project Filters ──────────────────────────────────────────────────────────

class ProjectFilters {
  final String? search;
  final Province? province;
  final ProjectCategory? category;
  final ProjectStatus? status;
  final double? budgetMin;
  final double? budgetMax;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String sortBy;
  final String sortOrder;

  const ProjectFilters({
    this.search,
    this.province,
    this.category,
    this.status,
    this.budgetMin,
    this.budgetMax,
    this.dateFrom,
    this.dateTo,
    this.sortBy = 'date',
    this.sortOrder = 'desc',
  });

  ProjectFilters copyWith({
    String? search,
    Province? province,
    ProjectCategory? category,
    ProjectStatus? status,
    double? budgetMin,
    double? budgetMax,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortBy,
    String? sortOrder,
  }) {
    return ProjectFilters(
      search: search ?? this.search,
      province: province ?? this.province,
      category: category ?? this.category,
      status: status ?? this.status,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (search?.isNotEmpty == true) params['search'] = search!;
    if (province != null) params['province'] = province!.name;
    if (category != null) params['category'] = category!.name;
    if (status != null) params['status'] = status!.name;
    if (budgetMin != null) params['budgetMin'] = budgetMin!.toString();
    if (budgetMax != null) params['budgetMax'] = budgetMax!.toString();
    params['sortBy'] = sortBy;
    params['sortOrder'] = sortOrder;
    return params;
  }

  bool get isEmpty =>
      search == null &&
      province == null &&
      category == null &&
      status == null &&
      budgetMin == null &&
      budgetMax == null;
}
