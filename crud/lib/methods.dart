import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Methods {
  //función para crear un nuevo usuario
  static Future<void> createUser(
    String name,
    String lastName,
    String middleLastName,
    String birthday,
    String email,
    String rfc,
    String curp,
    String password,
    File? imageFile,
  ) async {
    try {
      //crear una instancia de para realizar una solicitud POST
      //aqui uso MultipartRequest ya que como se envia una imagen, ayuda a enviarlo de forma binaria
      //para mejorar el envio de la imagen a la petición del servidor
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://miwws.com/PROYECTOS_MIW/flutter/public/api/users'),
      );

      //establecer campos de formulario para los datos del usuario
      request.fields['name'] = name;
      request.fields['last_name'] = lastName;
      request.fields['m_last_name'] = middleLastName;
      request.fields['birthday'] = birthday;
      request.fields['email'] = email;
      request.fields['rfc'] = rfc;
      request.fields['curp'] = curp;
      request.fields['password'] = password;

      //adjuntar un archivo si está presente
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: 'user_image.${imageFile.path.split('.').last}',
          ),
        );
      }

      //enviar la solicitud y manejar la respuesta
      var response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${await response.stream.bytesToString()}');
    } catch (e) {
      print('Error: $e');
    }
  }

  //función para obtener la lista de usuarios
  static Future<List<Map<String, dynamic>>> readUsers() async {
    const String url = 'https://miwws.com/PROYECTOS_MIW/flutter/public/api/users';

    try {
      //realiza una solicitud GET para obtener la lista de usuarios
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        //decodifica la respuesta usando json.decode y retornar la lista de usuarios
        final List<dynamic> userList = json.decode(response.body)['users'];
        return List<Map<String, dynamic>>.from(userList);
      } else {
        throw Exception('Error al cargar la información del usuario');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //función para actualizar un usuario existente
  static Future<void> updateUser(
    Map<String, dynamic> user,
    String name,
    String lastName,
    String middleLastName,
    String birthday,
    String email,
    String rfc,
    String curp,
    String password,
  ) async {
    try {
      //crea una instancia de http.MultipartRequest para realizar una solicitud POST de actualización
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://miwws.com/PROYECTOS_MIW/flutter/public/api/update/user'),
      );

      //establece campos de formulario para los datos actualizados del usuario
      request.fields['id'] = user['id'].toString();
      request.fields['name'] = name;
      request.fields['last_name'] = lastName;
      request.fields['m_last_name'] = middleLastName;
      request.fields['birthday'] = birthday;
      request.fields['email'] = email;
      request.fields['rfc'] = rfc;
      request.fields['curp'] = curp;

      //agrega el campo de contraseña solo si no está vacío
      //esto ayuda a enviar la consulta al servidor pero no agrega el campo al json de users
      if (password.isNotEmpty) {
        request.fields['password'] = password;
      }

      //envia la solicitud y maneja la respuesta en terminal
      var response = await request.send();
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${await response.stream.bytesToString()}');
    } catch (e) {
      print('Error: $e');
    }
  }

  //función para eliminar un usuario
  static Future<void> deleteUser(int userId) async {
    try {
      const url = 'https://miwws.com/PROYECTOS_MIW/flutter/public/api/delete/user';
      //realiza una solicitud DELETE con el ID del usuario a eliminar
      final response = await http.delete(
        Uri.parse(url),
        body: {'id': userId.toString()},
      );

      if (response.statusCode == 200) {
        print('User deleted successfully.');
      } else {
        print('Error deleting user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  //función para obtener la imagen de un usuario
  //esta parte tuve que buscar ya que me salia un error por cada usuario al no encontrar la imagen
  //esta funcion junto con el codigo de crud.dart ayuda a obtener la imagen sin tener que mostrar los errores en consola
  //ver crud.dart para visualizar la logica
  static Future<ImageProvider?> getImage(String imageUrl) async {
    try {
      //realizar una solicitud GET para obtener la imagen
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        //retornar la imagen como un objeto ImageProvider
        return MemoryImage(response.bodyBytes);
      } else {
        //retorna null o cualquier alternativa si hay un error de red diferente al código 404
        return null;
      }
    } catch (e) {
      //maneja cualquier error de red que pueda ocurrir
      return null;
    }
  }
}
