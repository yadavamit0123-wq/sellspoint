import 'dart:io';

sealed class FileResource {
  const FileResource();

  static FileResource fromPath(String path) {
    final uri = Uri.tryParse(path);
    if (uri == null) return LocalFileResource(File(path));
    if (uri.isScheme('http') || uri.isScheme('https')) {
      return RemoteFileResource(uri);
    } else {
      return LocalFileResource(File(path));
    }
  }

  String get filePath;
}

class RemoteFileResource extends FileResource {
  RemoteFileResource(this.url, {this.id});

  final int? id;
  final Uri url;

  @override
  String get filePath => url.toString();
}

class LocalFileResource extends FileResource {
  LocalFileResource(this.file);

  final File file;

  @override
  String get filePath => file.path;
}
