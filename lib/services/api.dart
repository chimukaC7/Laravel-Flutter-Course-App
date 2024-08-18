import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:my_first_app/models/category.dart';
import 'package:my_first_app/models/transaction.dart';

class ApiService {
  late String token;

  //constructor
  ApiService(String token) {
    this.token = token;
  }

  final String baseUrl = 'http://flutter-api.laraveldaily.com/api/';

  Future<List<Category>> fetchCategories() async {
    try {
      // Make an HTTP GET request and set a timeout of 10 seconds
      http.Response response = await http.get(Uri.parse(baseUrl + 'categories'),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
      ).timeout(Duration(seconds: 30));

      // Check if the response was successful
      if (response.statusCode == 200) {

        if (response.body != 'null') {

        // Parse the JSON response body
        List jsonResponse = jsonDecode(response.body);

        // Convert the JSON list into a list of Model instances
        return jsonResponse.map((data) => Category.fromJson(data)).toList();

      } else {
        return [];
      }

        //if status is greater than 400, there is a problem
      } else if (response.statusCode >= 400) {
        //if we throw an exception or if any other code in there throws an exception.
        // In that case, as mentioned, the future will be rejected
        // and that would lead to this hasError property
        throw Exception('Failed to fetch items. Please try again later.');
      } else {
        // Handle different HTTP status codes as needed
        throw Exception('Failed to load API data: ${response.statusCode}');
      }

    } on http.ClientException catch (e) {
      // Handle client-side errors (e.g., bad request)
      throw Exception('Client Error: $e');
    } on FormatException catch (e) {
      // Handle JSON format errors
      throw Exception('Bad response format: $e');
    } on TimeoutException catch (e) {
      // Handle timeout errors
      throw Exception('Request timeout: $e');
    } on Exception catch (e) {
      // Handle any other exceptions
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Category> addCategory(String name) async {
    String uri = baseUrl + 'categories';

    http.Response response = await http.post(Uri.parse(uri),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        body: jsonEncode({'name': name}));

    if (response.statusCode != 201) {
      throw Exception('Error happened on create');
    }

    return Category.fromJson(jsonDecode(response.body));
  }

  Future<Category> updateCategory(Category category) async {
    String uri = baseUrl + 'categories/' + category.id.toString();

    http.Response response = await http.put(Uri.parse(uri),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        body: jsonEncode({'name': category.name}));

    if (response.statusCode != 200) {
      throw Exception('Error happened on update');
    }

    return Category.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteCategory(id) async {
    String uri = baseUrl + 'categories/' + id.toString();

    http.Response response = await http.delete(Uri.parse(uri),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error happened on delete');
    }
  }

  Future<List<Transaction>> fetchTransactions() async {

    http.Response response = await http.get( Uri.parse(baseUrl + 'transactions'),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
    );

    List transactions = jsonDecode(response.body);

    return transactions.map((transaction) => Transaction.fromJson(transaction)).toList();
  }

  Future<Transaction> addTransaction(String amount, String category, String description, String date) async {
    String uri = baseUrl + 'transactions';

    http.Response response = await http.post(Uri.parse(uri),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        body: jsonEncode({
          'amount': amount,
          'category_id': category,
          'description': description,
          'transaction_date': date
        }));

    if (response.statusCode != 201) {
      throw Exception('Error happened on create');
    }

    return Transaction.fromJson(jsonDecode(response.body));
  }

  Future<Transaction> updateTransaction(Transaction transaction) async {
    String uri = baseUrl + 'transactions/' + transaction.id.toString();

    http.Response response = await http.put(Uri.parse(uri),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        body: jsonEncode({
          'amount': transaction.amount,
          'category_id': transaction.categoryId,
          'description': transaction.description,
          'transaction_date': transaction.transactionDate
        }));

    if (response.statusCode != 200) {
      throw Exception('Error happened on update');
    }

    return Transaction.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteTransaction(id) async {
    String uri = baseUrl + 'transactions/' + id.toString();

    http.Response response = await http.delete(
      Uri.parse(uri),
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token'
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error happened on delete');
    }
  }

  Future<String> register(String name, String email, String password, String passwordConfirm, String deviceName) async {
    String uri = baseUrl + 'auth/register';

    http.Response response = await http.post(Uri.parse(uri),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirm,
          'device_name': deviceName
        }));

    if (response.statusCode == 422) {
      Map<String, dynamic> body = jsonDecode(response.body);

      Map<String, dynamic> errors = body['errors'];
      String errorMessage = '';

      errors.forEach((key, value) {
        value.forEach((element) {
          errorMessage += element + '\n';
        });
      });

      throw Exception(errorMessage);
    }

    // return token
    return response.body;
  }

  Future<String> login(String email, String password, String deviceName) async {
    String uri = baseUrl + 'auth/login';

    http.Response response = await http.post(Uri.parse(uri),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': deviceName
        }));

    if (response.statusCode == 422) {
      Map<String, dynamic> body = jsonDecode(response.body);

      Map<String, dynamic> errors = body['errors'];
      String errorMessage = '';

      errors.forEach((key, value) {
        value.forEach((element) {
          errorMessage += element + '\n';
        });
      });

      throw Exception(errorMessage);
    }

    // return token
    return response.body;
  }
}
