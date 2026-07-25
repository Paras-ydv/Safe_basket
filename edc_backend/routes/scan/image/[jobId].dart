import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:edc_backend/response_envelope.dart';

// Import the job store from the image index route.
import 'index.dart' show jobStore;

/// GET /scan/image/:jobId
/// Poll the status of an async OCR job submitted via POST /scan/image.
/// Returns: { status: 'pending' | 'done' | 'failed', result?: {...}, error?: '...' }
Future<Response> onRequest(RequestContext context, String jobId) async {
  if (context.request.method != HttpMethod.get) {
    return errorResponse('method_not_allowed', 'Only GET is supported.',
        statusCode: HttpStatus.methodNotAllowed);
  }

  final job = jobStore[jobId];

  if (job == null) {
    // Job not found — either invalid ID or server was restarted.
    return errorResponse(
      'job_not_found',
      'No job found with id "$jobId".',
      statusCode: HttpStatus.notFound,
    );
  }

  // Return the current job state (pending, done, or failed).
  return okResponse(job);
}
