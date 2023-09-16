import 'package:camera_app/detections.dart';
import 'package:gsheets/gsheets.dart';

class UserSheetsApi{
  static const _credentials = r'''
  {
    "type": "service_account",
    "project_id": "gsheets-398510",
    "private_key_id": "f155dedb014c02218589b19eb0cb8ee50f12e5cd",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDLKnqJKNuRnJLD\nqXYAmIDzzdST1b4wWbMJy4lH3TezIUz7ePAu48WQ41fWDAqLRh2oTJf4xyfM03vS\n+iClK7svEp2Icb8KZO0b6xQgdBmeYuyaRoYEvc8opww55zz44xPre5kR0xxxA5Ah\nA8Ah6s4doeru2PnTE6EtSnPZAJPYwkqS/LKY91XfRox9l6Q2cVqHmMfsyRI8/De2\nIb++O3X6bo6nTlJL07C2/l2oo2FZBAO7J5KppeG1DQogC9gwtV5qO32q2rZgv7J0\nZ8m4zgxbu62zckMvirXa40d5rI7GKUFuO9zsgGTamqWzongG9z9mz5iHgIoIW0Zg\nqzVLIBOVAgMBAAECggEACyoJFG3GWGNo5+TxXb8Dobd3La3ahwBRh6xDnaCuZY2N\nlBQP6W5iy5TH8t8z2nYT6HetB41fcTCokUNldS4eBHbavpthisoDrZERc2cYhqJG\nVi6h7AjHes2915YOvQPdcwdBC2sKbmYVDtC3R3sxBbfWwnacjoN5oT+CIN6Ylpny\n0goZM+eE3PXrTa1gBAKv6n7ju42rPLBY3XpjxENXR6zP/t54C7RlOv4ulExQCXaG\n9f+4PJTVKLZfciLS01MOEQHNIReJbyHIjljULSeylTQSUfGv2Kwzswq4jinLjwzr\nLPsn4wgfsqFFzseIu36kAHrkGY/uSckRmWi82OFdUQKBgQD3Ezo+AmFDLFEDsZ81\n0fymxlRuUPlJ0VEjrPFcDaMFa2XdzpcOzHvCYqfBdw/ZgAihaP0s4bxJT37xux7R\nVvGQoppETeqAqSp1UAIZlFH9X7FR1R80kTq6bQwcdMTcqwvihFgvt9mro1eLLs5Z\n9o+ElJbKfUHsJdle7RudL4kEbwKBgQDSgTXzc18kGrwUPxRdnNjjuWPxXepoPbrL\nx16+NJeegIatLDst7DbJUGY7V5EjKPu7qSwiXwKWlLGgXfC/5cNTai+3NuJhyh7h\nk2Fu40j9q6sLWhszCSAvzRyTTwuW8FXLxncv2J6RZvZNCGHZCejzRxG24a08PAZz\nK41A/CfSOwKBgCAJnDnCMT52lqK1+4ENE4fEm9oaIdkSjUTk/f8DvanMPU8/pJLE\nrR+Nj1ckyydW1MepR3r0YmfXKQzLSLm4XmZ0zzAgMlIwnVLM5xjOBLuoFuQXkI5O\nbqER1sox0f0TKN1cb9rwKgd5jLZ9gUBlGkMEyXDEQTIPzlniwPvm2At9AoGAcG0m\nHWIO/D9zF/UgsWalx+op4K1iFk5xx4gxp7B7EeJfC3pGGR7Bm/9eum7oSzkGSZHu\nymSoAzhjLd0+SZ8zFQfveBDOE6BZoeyO6yRkxWa8MZHsWPOUxzLrAhoDfJfbmrvi\nyCEPf2TYQwgpCjvquJPKeDxLw5Hjd/tYs854jiUCgYEAx1oJxU+YXEnsadNeKAQR\nArAzXcp0LIy8C/mNmuYibnAc5++s/X9ozvkYBh6r/R+vqRVM8MBQQxhzzVO2kLTS\nM9sNjplMHI6lqBusH2sA87VW3ze7/DpY8hHJXBYbOtt9HayYVixgVSk/+ZXEY4O1\n6X1xk+vqhj5vS8fug05mWss=\n-----END PRIVATE KEY-----\n",
    "client_email": "gsheets@gsheets-398510.iam.gserviceaccount.com",
    "client_id": "105067496752015434327",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-398510.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  }
  ''';
  static const _spreadsheetId='1Vt5FoBRMHUytv8ZQnv6tfhOzo5pSbZ4TcLu91jVR2Fc';
  static final _gsheets=GSheets(_credentials);
  static Worksheet? userSheet;

  static Future init() async {
    try {
      print("-----inititalising------");
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      userSheet = await _getWorkSheet(spreadsheet, title: "Users");
      final firstRow = DetectionFields.getFields();
      userSheet!.values.insertRow(1, firstRow);
    }catch(e){
      print('Init Error :$e');
    }
  }

  static Future<Worksheet> _getWorkSheet(
    Spreadsheet spreadsheet, {
      required String title,}) async {
    try{
      return await spreadsheet.addWorksheet(title);
    }catch(e){
      return spreadsheet.worksheetByTitle(title)!;
    }

  }
}