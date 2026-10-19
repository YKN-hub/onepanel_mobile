/// 文件信息
class FileInfo {
  final String name;
  final String path;
  final String type; // dir, file, link
  final int size;
  final DateTime? modTime;
  final String? mode;
  final String? owner;
  final String? group;
  final String? linkPath;
  final bool? hidden;

  FileInfo({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    this.modTime,
    this.mode,
    this.owner,
    this.group,
    this.linkPath,
    this.hidden,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      type: json['type'] ?? 'file',
      size: json['size'] ?? 0,
      modTime: json['modTime'] != null
          ? DateTime.parse(json['modTime'])
          : null,
      mode: json['mode'],
      owner: json['owner'],
      group: json['group'],
      linkPath: json['linkPath'],
      hidden: json['hidden'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'type': type,
    'size': size,
    'modTime': modTime?.toIso8601String(),
    'mode': mode,
    'owner': owner,
    'group': group,
    'linkPath': linkPath,
    'hidden': hidden,
  };

  bool get isDir => type == 'dir';
  bool get isFile => type == 'file';
  bool get isLink => type == 'link';

  /// 获取文件扩展名
  String get extension {
    if (!isFile) return '';
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  /// 获取文件大小显示
  String get sizeDisplay {
    if (size == 0) return '0 B';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 获取文件图标
  String get icon {
    if (isDir) return 'folder';
    switch (extension) {
      case 'txt':
      case 'md':
      case 'log':
        return 'document';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'pdf':
        return 'pdf';
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
        return 'archive';
      case 'sh':
      case 'bash':
        return 'script';
      default:
        return 'file';
    }
  }
}
