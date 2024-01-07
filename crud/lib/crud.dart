import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'methods.dart';

// Clase principal para la funcionalidad CRUD
class Crud extends StatefulWidget {
  const Crud({super.key});

  @override
  _CrudState createState() => _CrudState();
}

class _CrudState extends State<Crud> {
  // Controladores de texto para los campos de entrada del formulario
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mLastNameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController rfcController = TextEditingController();
  final TextEditingController curpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  //Varible para guardar la imagen seleccionada
  File? imageFile;
  // Listas para almacenar usuarios y usuarios filtrados
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> filteredUserList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _readUsers();
  }

  //funsión para crear un usuario nuevo (CREATE/POST)
  void _createUser() async {
    //se invoca la funsión para crear a un usuario desde la clase methods
    await Methods.createUser(
      nameController.text,
      lastNameController.text,
      mLastNameController.text,
      birthdayController.text,
      emailController.text,
      rfcController.text,
      curpController.text,
      passwordController.text,
      imageFile,
    );
    //realiza la lectura de usuarios desde la llamada al servidor.
    await _readUsers();
    //actualiza el estado del widget para reflejar los cambios en las listas de usuarios.
    setState(() {});
  }

  //funsión para leer a los usuarios (READ/GET)
  Future<void> _readUsers() async {
    //muestra el estado del widget mostrando un CircularProgressIndicator
    setState(() {
      isLoading = true;
    });
    //aqui se invoca la funsión estatic desde la clase methods para obtener la lista de usuarios
    final List<Map<String, dynamic>> userList = await Methods.readUsers();
    /*después de obtener la lista de usuarios, actualiza el estado del widget para indicar
    que se ha completado la carga. También actualiza las listas `userList` y `filteredUserList`
    con la información obtenida.*/
    setState(() {
      isLoading = false;
      this.userList = userList;
      filteredUserList = userList;
    });
  }

  //funsión para actualizar a un usuario seleccionado (UPDATE/POST)
  void _updateUser(Map<String, dynamic> user) async {
    await Methods.updateUser(
      user,
      nameController.text,
      lastNameController.text,
      mLastNameController.text,
      birthdayController.text,
      emailController.text,
      rfcController.text,
      curpController.text,
      passwordController.text,
    );
    await _readUsers();
    setState(() {});
  }

  //funsión para eliminar a un usuario seleccionado (DELETE/DELETE)
  //se encuentra dentro de un showdialog para la confirmación de la eliminación
  void _confirmDeleteUser(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content:
              const Text('¿Esta seguro que desea eliminar a este usuario?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            //aqui se invoca la funsión para eliminar al usuario, usando un await para una tarea asincrona
            ElevatedButton(
              onPressed: () async {
                await Methods.deleteUser(userId);
                Navigator.of(context).pop();
                await _readUsers();
                setState(() {});
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  /*selección de una imagen de la galería utilizando la biblioteca `image_picker`
    Actualiza el estado [imageFile] con la imagen seleccionada*/
  Future<void> _pickImage() async {
    // Crea una instancia de ImagePicker para manejar la selección de imágenes
    final ImagePicker _picker = ImagePicker();
    // Utiliza ImagePicker para seleccionar una imagen de la galería
    final XFile? pickedFile = await _picker.pickImage(
      //se especifica la fuente de donde seleccionar la imagen, la calidad y el dispositivo
      //aqui un margen de mejora es añadir la camara para agregar una foto usando la camara
      source: ImageSource.gallery,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.front,
    );
    //verifica si se seleccionó un archivo de imagen y actualiza el estado de imageFile con la ruta del archivo
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  //funsión para filtrar por name, last name o m last name
  void _filterUsers(String query) {
    //se toma el query para actualizar la lista de usuarios
    //como se usa un setState se actualiza en la interfaz cada que detecta un cambio en el onChanged del campo de texto
    setState(() {
      filteredUserList = userList
          .where((user) =>
              user['name'].toLowerCase().contains(query.toLowerCase()) ||
              user['last_name'].toLowerCase().contains(query.toLowerCase()) ||
              user['m_last_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  //a partir de aqui es el diseño del widget de la interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(0),
          child: Image.asset(
            'assets/logoMadeInWeb.png',
            height: 100,
            width: 100,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //este es un campo de texto interactivo para la busqueda
                  TextField(
                    /*la función [onChanged] se llama cada vez que el contenido del campo de texto cambia
                    y llama a la funsión para filtrar a los usuarios*/
                    onChanged: (value) {
                      _filterUsers(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Buscar por nombres o apellidos',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Usuarios: ${filteredUserList.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _showCreateUserForm,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Crear Usuario'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              //aqui se utilizo un SliverList, ya que siendo una gran cantidad de datos, un customScroll haria lenta la interfaz
              //utilizando el SliverList solo renderizalos elementos visibles, asi que la interfaz se hace mucho mas fluida
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = filteredUserList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          //aqui se añade un ExpansionTile para mejorar la lectura de la información de los usuarios
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              child: FutureBuilder(
                                future: Methods.getImage(user['image']),
                                builder: (context, snapshot) {
                                  //solo evalua si el Future ha terminado
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    //comprueba si hay algún error en el Future o si los datos obtenidos son nulos.
                                    //si hay un error o no hay datos, devuelve un Icon con un ícono de error.
                                    if (snapshot.hasError ||
                                        snapshot.data == null) {
                                      return const Icon(Icons.error);
                                    }
                                    //si no hay errores evalua la imagen obtenida por el url del campo y procede a mostrarla en un circleAvatar
                                    return CircleAvatar(
                                      backgroundImage: snapshot.data,
                                    );
                                  } else {
                                    /*mientras el Future se esta ejecutando devuelve 
                                    un circularProgressIndicator para dar una mejor perspectiva del progreso*/
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                            //los siguientes son los datos obtenidos de la variable user que devuelve la lista de usuarios obtenidos por el metodo
                            title: Text(
                              '${user['name']} ${user['last_name']} ${user['m_last_name']}',
                            ),
                            children: [
                              ListTile(
                                title: Text('User ID: ${user['id']}'),
                              ),
                              ListTile(
                                title: Text('Email: ${user['email']}'),
                              ),
                              ListTile(
                                title: Text('Birthday: ${user['birthday']}'),
                              ),
                              ListTile(
                                title: Text('RFC: ${user['rfc']}'),
                              ),
                              ListTile(
                                title: Text('CURP: ${user['curp']}'),
                              ),
                              ListTile(
                                title:
                                    Text('Created At: ${user['created_at']}'),
                              ),
                              ListTile(
                                title:
                                    Text('Updated At: ${user['updated_at']}'),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //boton que llama a la funcion para mostrar el formulario de actualizar
                                  ElevatedButton(
                                    onPressed: () {
                                      _editUser(user);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text('Actualizar'),
                                  ),
                                  const SizedBox(width: 10.0),
                                  //boton que llama a la funcion para eliminar al usuario seleccionado segun el campo del id del mismo
                                  ElevatedButton(
                                    onPressed: () {
                                      _confirmDeleteUser(user['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                  const SizedBox(width: 10.0),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredUserList.length,
                  ),
                ),
        ],
      ),
    );
  }

  //esta es la funcion que crea un formulario para crear un nuevo usuario
  //se me hizo mejor meterlo en un ModalBottomSheet, para tener mejor manejo de los hilos que se estan ejecutando en el momento
  //y asi no ocupar mandar a una pantalla nueva
  //solo son inputs que al mismo tiempo llaman a los controladores para asignarles un texto o en caso de image un archivo
  void _showCreateUserForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Crear Usuario Nuevo',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre(s)',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Primer Apellido',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: mLastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Segundo Apellido',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: birthdayController,
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Nacimiento',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: rfcController,
                              decoration: const InputDecoration(
                                labelText: 'RFC',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(),
                      ),
                      child: TextFormField(
                        controller: curpController,
                        decoration: const InputDecoration(
                          labelText: 'CURP',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          //al presionar llamamos a la funsión para seleccionar la imagen
                          onPressed: _pickImage,
                          child: const Text('Seleccionar Imagen'),
                        ),
                      ),
                      //es solo diseño, para mostrar un icon de de carga de archivo que cambia al tener una imagen seleccionada
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: imageFile == null
                            ? const Icon(
                                Icons.file_upload,
                                size: 30.0,
                              )
                            : const Icon(
                                Icons.image,
                                size: 30.0,
                              ),
                      ),
                      //si imageFile es diferente a nulo y ya hay una imagen seleccionada, muestra el nombre del archivo
                      if (imageFile != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              //se obtiene la ruta completa del archico seleccionado para usar el metodo split
                              //que divide el nombre segun diagonales y el metodo last, muestra el ultimo elemento seleccionado en la lista
                              'Selected Image: ${imageFile!.path.split('/').last}',
                              style: const TextStyle(fontSize: 16.0),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              //se actualizan los campos de texto para limpiarlos, y a imageFile lo devuelve nulo
                              nameController.clear();
                              lastNameController.clear();
                              mLastNameController.clear();
                              birthdayController.clear();
                              rfcController.clear();
                              emailController.clear();
                              curpController.clear();
                              passwordController.clear();
                              imageFile = null;
                            });
                          },
                          child: const Text('Limpiar Formulario'),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 20.0),
                    //aqui al presionar el boton se llama a la función de createUser()
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _createUser();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Crear Usuario'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

//esta es la función para mostrar el formulario para actualizar a un usuario, basicamente la misma logica del formulario anterior
  void _editUser(Map<String, dynamic> user) {
    nameController.text = user['name'];
    lastNameController.text = user['last_name'];
    mLastNameController.text = user['m_last_name'];
    birthdayController.text = user['birthday'];
    emailController.text = user['email'];
    rfcController.text = user['rfc'];
    curpController.text = user['curp'];
    passwordController.text = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Editar Usuario',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre(s)',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Primer Apellido',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: mLastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Segundo Apellido',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: birthdayController,
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Nacimiento',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(),
                            ),
                            child: TextFormField(
                              controller: rfcController,
                              decoration: const InputDecoration(
                                labelText: 'RFC',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(),
                      ),
                      child: TextFormField(
                        controller: curpController,
                        decoration: const InputDecoration(
                          labelText: 'CURP',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _updateUser(user);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Actualizar Usuario'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}