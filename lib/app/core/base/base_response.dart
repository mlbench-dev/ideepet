import 'package:get/get.dart';
import 'package:idee_pet/lib.dart';

class BaseResponse<T> {
  final bool success;
  final int? statusCode;
  final T? result;
  final List<dynamic> errorMessages;

  BaseResponse._({
    required this.success,
    required this.errorMessages,
    this.statusCode,
    this.result,
  });

  static BaseResponse<T> createCustom<T>({
    required final bool success,
    final int? statusCode,
    final T? result,
    final List<dynamic>? errorMessages,
  }) =>
      BaseResponse._(
        success: success,
        statusCode: statusCode,
        result: result,
        errorMessages: errorMessages ?? [],
      );

  // Factory para criar a partir de uma Response singular
  static BaseResponse<T> create<T>({
    required final Response<dynamic> response,
    final T Function(dynamic data)? fromMap,
  }) {
    final requestUrl = response.request?.url.toString();
    final responseStatusCode = response.statusCode;
    dynamic responseBody = response.body;
    final statusText = response.statusText;

    dynamic responseData;
    List<dynamic> parsedErrorMessages = [];
    bool parseErrorOccurred = false;

    // --- Extração de Dados e Erros ---

    if (responseBody is Map) {
      responseData = responseBody.containsKey('data')
          ? responseBody['data']
          : responseBody;
      try {
        final errors = responseBody['errorMessages'];
        if (errors is List) {
          parsedErrorMessages = errors;
        } else if (errors != null) {
          BugTracking().log(
              'BaseResponse.create: errorMessages field found but is not a List.',
              {
                'url': requestUrl ?? 'N/A',
                'statusCode': responseStatusCode?.toString() ?? 'N/A',
                'errorMessagesType': errors.runtimeType.toString()
              });
        }
      } catch (e, s) {
        BugTracking().log(
            'BaseResponse.create: Exception while accessing errorMessages.', {
          'url': requestUrl ?? 'N/A',
          'statusCode': responseStatusCode?.toString() ?? 'N/A',
          'exception': e.toString()
        });
      }
    } else {
      responseData = responseBody;
    }

    // --- Processamento do Resultado ---
    T? processedResult;
    if (responseData != null && fromMap != null) {
      try {
        processedResult = fromMap(responseData);
      } catch (e, s) {
        parseErrorOccurred = true;

        BugTracking().send(
          'BaseResponse.create: Failed to map response data',
          e,
          s,
          responseData?.toString(),
          requestUrl,
          responseStatusCode?.toString(),
        );
      }
    }

    // --- Determinação do Sucesso e Reporte de Erro HTTP ---
    final bool isSuccess =
        responseStatusCode != null && responseStatusCode > 0 && responseStatusCode < 400;

    if (!isSuccess && !parseErrorOccurred) {
      BugTracking().send(
        'API Error Response: Status $responseStatusCode', // Mensagem clara
        ApiResponseException(responseStatusCode ?? 500,
            reasonPhrase: statusText,
            url: requestUrl,
            responseBody: responseBody),
        StackTrace.current,
        responseBody?.toString(),
        requestUrl,
        responseStatusCode?.toString(),
      );
    }

    return BaseResponse._(
      statusCode: responseStatusCode,
      errorMessages: parsedErrorMessages,
      success: isSuccess,
      result: processedResult,
    );
  }

  // Factory para criar a partir de uma Response de lista
  static BaseResponse<List<T>> createList<T>({
    required final Response<dynamic> response,
    final T Function(dynamic data)? fromMap,
  }) {
    final requestUrl = response.request?.url.toString();
    final responseStatusCode = response.statusCode;
    dynamic responseBody = response.body;
    final statusText = response.statusText;

    dynamic responseData;
    List<dynamic> parsedErrorMessages = [];
    bool parseErrorOccurred = false;
    int parseErrorItemCount = 0;

    // --- Extração de Dados e Erros ---

    if (responseBody is Map) {
      responseData =
          responseBody.containsKey('data') ? responseBody['data'] : null;
      try {
        final errors = responseBody['errorMessages'];
        if (errors is List) {
          parsedErrorMessages = errors;
        } else if (errors != null) {
          BugTracking().log(
              'BaseResponse.createList: errorMessages field found but is not a List.',
              {
                'url': requestUrl ?? 'N/A',
                'statusCode': responseStatusCode?.toString() ?? 'N/A',
                'errorMessagesType': errors.runtimeType.toString()
              });
        }
      } catch (e, s) {
        BugTracking().log(
            'BaseResponse.createList: Exception while accessing errorMessages.',
            {
              'url': requestUrl ?? 'N/A',
              'statusCode': responseStatusCode?.toString() ?? 'N/A',
              'exception': e.toString()
            });
      }
      if (responseData != null && responseData is! List) {
        BugTracking().log(
            'BaseResponse.createList: Field "data" was found but is not a List.',
            {
              'url': requestUrl ?? 'N/A',
              'statusCode': responseStatusCode?.toString() ?? 'N/A',
              'dataType': responseData.runtimeType.toString()
            });
        responseData = null;
      }
    } else if (responseBody is List) {
      responseData = responseBody;
    } else {
      BugTracking().log(
          'BaseResponse.createList: Response body is neither a Map nor a List.',
          {
            'url': requestUrl ?? 'N/A',
            'statusCode': responseStatusCode?.toString() ?? 'N/A',
            'bodyType': responseBody?.runtimeType.toString() ?? 'null'
          });
      responseData = null;
    }

    // --- Processamento da Lista ---
    List<T> processedList = [];
    if (responseData != null && responseData is List && fromMap != null) {
      final List<dynamic> dataList = responseData;
      for (int i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        try {
          processedList.add(fromMap(item));
        } catch (e, s) {
          parseErrorOccurred = true;
          parseErrorItemCount++;

          BugTracking().send(
            'BaseResponse.createList: Failed to map item at index $i',
            e,
            s,
            item?.toString(),
            requestUrl,
            responseStatusCode?.toString(),
          );
        }
      }
    } else if (responseData != null &&
        responseData is List &&
        fromMap == null) {
      try {
        processedList = List<T>.from(responseData);
      } catch (e, s) {
        parseErrorOccurred = true;

        BugTracking().send(
          'BaseResponse.createList: Failed to cast response list to List<$T>',
          e,
          s,
          responseData?.toString(),
          requestUrl,
          responseStatusCode?.toString(),
        );
      }
    }

    // --- Determinação do Sucesso e Reporte de Erro HTTP ---
    final bool isSuccess =
        responseStatusCode != null && responseStatusCode > 0 && responseStatusCode < 400;

    if (!isSuccess) {
      BugTracking().send(
        'API Error Response: Status $responseStatusCode', // Mensagem clara
        ApiResponseException(responseStatusCode ?? 500,
            reasonPhrase: statusText,
            url: requestUrl,
            responseBody: responseBody),
        StackTrace.current,
        responseBody?.toString(),
        requestUrl,
        responseStatusCode?.toString(),
      );

      if (parseErrorItemCount > 0) {
        BugTracking().log(
            "Note: $parseErrorItemCount items failed to parse in this error response.",
            {
              'url': requestUrl ?? 'N/A',
              'statusCode': responseStatusCode?.toString() ?? '500',
            });
      }
    }

    return BaseResponse._(
      statusCode: responseStatusCode,
      errorMessages: parsedErrorMessages,
      success: isSuccess,
      result: processedList,
    );
  }
}
