/// Course List API Response
class CourseListResponse {
  final bool status;
  final String message;
  final CourseListData data;

  CourseListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CourseListResponse.fromJson(Map<String, dynamic> json) {
    return CourseListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: CourseListData.fromJson(json['data'] ?? {}),
    );
  }
}

class CourseListData {
  final List<Course> courses;
  final Pagination pagination;

  CourseListData({
    required this.courses,
    required this.pagination,
  });

  factory CourseListData.fromJson(Map<String, dynamic> json) {
    return CourseListData(
      courses: (json['courses'] as List<dynamic>?)
              ?.map((item) => Course.fromJson(item))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

/// Course Detail API Response
class CourseDetailResponse {
  final bool status;
  final String message;
  final CourseDetailData data;

  CourseDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CourseDetailResponse.fromJson(Map<String, dynamic> json) {
    return CourseDetailResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: CourseDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class CourseDetailData {
  final Course course;
  final Enrollment enrollment;
  final bool isEnrolled;
  final List<CourseModule> modules;

  CourseDetailData({
    required this.course,
    required this.enrollment,
    required this.isEnrolled,
    required this.modules,
  });

  factory CourseDetailData.fromJson(Map<String, dynamic> json) {
    return CourseDetailData(
      course: Course.fromJson(json['course'] ?? {}),
      enrollment: Enrollment.fromJson(json['enrollment'] ?? {}),
      isEnrolled: json['is_enrolled'] ?? false,
      modules: (json['modules'] as List<dynamic>?)
              ?.map((item) => CourseModule.fromJson(item))
              .toList() ??
          [],
    );
  }
}

/// Enrollment API Response
class EnrollmentResponse {
  final bool status;
  final String message;
  final Enrollment data;

  EnrollmentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EnrollmentResponse.fromJson(Map<String, dynamic> json) {
    return EnrollmentResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: Enrollment.fromJson(json['data'] ?? {}),
    );
  }
}

/// Course Model
class Course {
  final int id;
  final String title;
  final String description;
  final String author;
  final int duration;
  final String status;
  final double rating;
  final String thumbnailUrl;
  final bool isPublished;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.duration,
    required this.status,
    required this.rating,
    required this.thumbnailUrl,
    required this.isPublished,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['ID'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      thumbnailUrl: json['thumbnail_url'] ?? '',
      isPublished: json['is_published'] ?? false,
      isDeleted: json['IsDeleted'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }

  String get durationString {
    // Duration is stored in hours
    if (duration <= 0) {
      return '0h';
    }
    return '${duration}h';
  }

  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 97)}...';
  }
}

/// Course Module Model
class CourseModule {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final int orderIndex;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['ID'] ?? 0,
      courseId: json['course_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      orderIndex: json['order_index'] ?? 0,
      isDeleted: json['IsDeleted'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }
}

/// Enrollment Model
class Enrollment {
  final int id;
  final int userId;
  final int courseId;
  final String status;
  final double progress;
  final int completedContents;
  final int totalContents;
  final DateTime? completedAt;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.status,
    required this.progress,
    required this.completedContents,
    required this.totalContents,
    this.completedAt,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['ID'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      status: json['status'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      completedContents: json['completed_contents'] ?? 0,
      totalContents: json['total_contents'] ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      isDeleted: json['IsDeleted'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isEnrolled => status == 'ENROLLED';

  int get progressPercent => (progress * 100).toInt();
}

/// Pagination Model
class Pagination {
  final int limit;
  final int page;
  final int total;

  Pagination({
    required this.limit,
    required this.page,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      limit: json['limit'] ?? 10,
      page: json['page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  int get totalPages => (total / limit).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

// =====================================================
// Course Content Models
// =====================================================

/// Course Content Response
class CourseContentResponse {
  final bool status;
  final String message;
  final CourseContentData data;

  CourseContentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CourseContentResponse.fromJson(Map<String, dynamic> json) {
    return CourseContentResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: CourseContentData.fromJson(json['data'] ?? {}),
    );
  }
}

class CourseContentData {
  final List<CourseContent> contents;
  final Pagination pagination;

  CourseContentData({
    required this.contents,
    required this.pagination,
  });

  factory CourseContentData.fromJson(Map<String, dynamic> json) {
    return CourseContentData(
      contents: (json['contents'] as List<dynamic>?)
              ?.map((item) => CourseContent.fromJson(item))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

/// Course Content Model (TEXT, VIDEO, MCQ)
class CourseContent {
  final int id;
  final int courseId;
  final int moduleId;
  final int day;
  final String title;
  final String description;
  final String contentType; // TEXT, VIDEO, MCQ
  final String textContent;
  final String videoUrl;
  final String imageUrl;
  final int orderIndex;
  final bool isPublished;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseContent({
    required this.id,
    required this.courseId,
    required this.moduleId,
    required this.day,
    required this.title,
    required this.description,
    required this.contentType,
    required this.textContent,
    required this.videoUrl,
    required this.imageUrl,
    required this.orderIndex,
    required this.isPublished,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      id: json['ID'] ?? 0,
      courseId: json['course_id'] ?? 0,
      moduleId: json['module_id'] ?? 0,
      day: json['day'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      contentType: json['content_type'] ?? 'TEXT',
      textContent: json['text_content'] ?? '',
      videoUrl: json['video_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      orderIndex: json['order_index'] ?? 0,
      isPublished: json['is_published'] ?? false,
      isDeleted: json['IsDeleted'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }

  bool get isText => contentType == 'TEXT';
  bool get isVideo => contentType == 'VIDEO';
  bool get isMcq => contentType == 'MCQ';

  String get youtubeVideoId {
    if (videoUrl.isEmpty) return '';
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return '';

    // Handle youtu.be format
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }

    // Handle youtube.com format
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }

    return '';
  }
}

// =====================================================
// User Enrollments Models
// =====================================================

/// User Enrollments Response
class UserEnrollmentsResponse {
  final bool status;
  final String message;
  final UserEnrollmentsData data;

  UserEnrollmentsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserEnrollmentsResponse.fromJson(Map<String, dynamic> json) {
    return UserEnrollmentsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: UserEnrollmentsData.fromJson(json['data'] ?? {}),
    );
  }
}

class UserEnrollmentsData {
  final List<EnrolledCourse> enrollments;
  final int total;

  UserEnrollmentsData({
    required this.enrollments,
    required this.total,
  });

  factory UserEnrollmentsData.fromJson(Map<String, dynamic> json) {
    return UserEnrollmentsData(
      enrollments: (json['enrollments'] as List<dynamic>?)
              ?.map((item) => EnrolledCourse.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}

/// Enrolled Course with course details
class EnrolledCourse {
  final int id;
  final int userId;
  final int courseId;
  final String status;
  final double progress;
  final int completedContents;
  final int totalContents;
  final DateTime? completedAt;
  final bool isDeleted;
  final String courseName;
  final String courseDescription;
  final String courseAuthor;
  final int courseDuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EnrolledCourse({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.status,
    required this.progress,
    required this.completedContents,
    required this.totalContents,
    this.completedAt,
    required this.isDeleted,
    required this.courseName,
    required this.courseDescription,
    required this.courseAuthor,
    required this.courseDuration,
    this.createdAt,
    this.updatedAt,
  });

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    return EnrolledCourse(
      id: json['ID'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      status: json['status'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      completedContents: json['completed_contents'] ?? 0,
      totalContents: json['total_contents'] ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      isDeleted: json['IsDeleted'] ?? false,
      courseName: json['course_name'] ?? '',
      courseDescription: json['course_description'] ?? '',
      courseAuthor: json['course_author'] ?? '',
      courseDuration: json['course_duration'] ?? 0,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isEnrolled => status == 'ENROLLED';
  int get progressPercent => progress.toInt();

  String get durationString {
    if (courseDuration < 60) {
      return '$courseDuration min';
    }
    final hours = courseDuration ~/ 60;
    final mins = courseDuration % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

// =====================================================
// Course Progress Models
// =====================================================

/// Course Progress Response
class CourseProgressResponse {
  final bool status;
  final String message;
  final CourseProgressData data;

  CourseProgressResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CourseProgressResponse.fromJson(Map<String, dynamic> json) {
    return CourseProgressResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: CourseProgressData.fromJson(json['data'] ?? {}),
    );
  }
}

class CourseProgressData {
  final List<int> completedIds;
  final Enrollment enrollment;
  final List<ModuleProgress> moduleProgress;

  CourseProgressData({
    required this.completedIds,
    required this.enrollment,
    required this.moduleProgress,
  });

  factory CourseProgressData.fromJson(Map<String, dynamic> json) {
    return CourseProgressData(
      completedIds: (json['completed_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      enrollment: Enrollment.fromJson(json['enrollment'] ?? {}),
      moduleProgress: (json['module_progress'] as List<dynamic>?)
              ?.map((item) => ModuleProgress.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ModuleProgress {
  final int moduleId;
  final String moduleName;
  final int totalContents;
  final int completedContents;
  final double progress;

  ModuleProgress({
    required this.moduleId,
    required this.moduleName,
    required this.totalContents,
    required this.completedContents,
    required this.progress,
  });

  factory ModuleProgress.fromJson(Map<String, dynamic> json) {
    return ModuleProgress(
      moduleId: json['module_id'] ?? 0,
      moduleName: json['module_name'] ?? '',
      totalContents: json['total_contents'] ?? 0,
      completedContents: json['completed_contents'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  int get progressPercent => progress.toInt();
}

// =====================================================
// Certificate Models
// =====================================================

/// User Certificates Response
class UserCertificatesResponse {
  final bool status;
  final String message;
  final UserCertificatesData data;

  UserCertificatesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserCertificatesResponse.fromJson(Map<String, dynamic> json) {
    return UserCertificatesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: UserCertificatesData.fromJson(json['data'] ?? {}),
    );
  }
}

class UserCertificatesData {
  final List<Certificate> certificates;
  final int pendingRequests;

  UserCertificatesData({
    required this.certificates,
    required this.pendingRequests,
  });

  factory UserCertificatesData.fromJson(Map<String, dynamic> json) {
    return UserCertificatesData(
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map((item) => Certificate.fromJson(item))
              .toList() ??
          [],
      pendingRequests: json['pending_requests'] ?? 0,
    );
  }
}

class Certificate {
  final int id;
  final int userId;
  final int courseId;
  final String courseName;
  final String certificateUrl;
  final String certificateNumber;
  final String status;
  final DateTime? issuedAt;
  final DateTime? createdAt;

  Certificate({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.courseName,
    required this.certificateUrl,
    required this.certificateNumber,
    required this.status,
    this.issuedAt,
    this.createdAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['ID'] ?? 0,
      userId: json['user_id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      certificateUrl: json['certificate_url'] ?? '',
      certificateNumber: json['certificate_number'] ?? '',
      status: json['status'] ?? '',
      issuedAt: json['issued_at'] != null
          ? DateTime.tryParse(json['issued_at'])
          : null,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }

  bool get isIssued => status == 'ISSUED' || certificateNumber.isNotEmpty;
  bool get isPending => status == 'PENDING';
}

/// Generic API Response for simple operations
class ApiResponse {
  final bool status;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
