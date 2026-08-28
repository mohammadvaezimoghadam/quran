import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/network_service.dart';
import 'i_file_download_service.dart';
import 'file_download_service_impl.dart';

/// Provider for the FileDownloadService.
final fileDownloadServiceProvider = Provider<IFileDownloadService>((ref) {
  final dio = ref.watch(networkServiceProvider);
  return FileDownloadServiceImpl(dio);
});
