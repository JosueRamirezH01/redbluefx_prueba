import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/error_dialog.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:convert';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus nodes para mejor gestión del focus en Android
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  late AnimationController _animationController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    print('🔧 [REGISTER-DEBUG] Initializing RegisterScreen');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )
      ..forward();

    // Agregar listeners para debugging del focus
    _fullNameFocus.addListener(() =>
        print('🔧 [REGISTER-DEBUG] FullName focus: ${_fullNameFocus.hasFocus}'));
    _emailFocus.addListener(() =>
        print('🔧 [REGISTER-DEBUG] Email focus: ${_emailFocus.hasFocus}'));
    _passwordFocus.addListener(() =>
        print('🔧 [REGISTER-DEBUG] Password focus: ${_passwordFocus.hasFocus}'));
    _confirmPasswordFocus.addListener(() =>
        print(
            '🔧 [REGISTER-DEBUG] Confirm password focus: ${_confirmPasswordFocus
                .hasFocus}'));
  }

  @override
  void dispose() {
    print('🔧 [REGISTER-DEBUG] Disposing RegisterScreen');
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      print('🔄 [UI-REGISTER] Form validation passed, starting registration');
      print('🔄 [UI-REGISTER] Email: ${_emailController.text}');
      print('🔄 [UI-REGISTER] FullName: ${_fullNameController.text}');

      try {
        print('🔄 [UI-REGISTER] Calling auth provider register method');
        await ref.read(authStateProvider.notifier).register(
          _emailController.text,
          _passwordController.text,
          _fullNameController.text,
        );

        if (!mounted) return;

        final authState = ref.read(authStateProvider);
        print('🔄 [UI-REGISTER] Auth state after registration:');
        print('  - isAuthenticated: ${authState.isAuthenticated}');
        print('  - isLoading: ${authState.isLoading}');
        print('  - error: ${authState.error}');
        print('  - user: ${authState.currentUser?.email}');

        if (authState.error != null) {
          print(
              '❌ [UI-REGISTER] Error found in auth state: ${authState.error}');
          String errorMessage = authState.error.toString();
          try {
            final errorJson = jsonDecode(
                errorMessage.replaceAll('Exception: ', ''));
            if (errorJson['message'] == 'Usuario registrado exitosamente') {
              print(
                  '✅ [UI-REGISTER] Registration successful, navigating to email verification');
              // Navegar a verificación de email
              context.go('/verify-email?email=${Uri.encodeComponent(
                  _emailController.text)}&fullName=${Uri.encodeComponent(
                  _fullNameController.text)}');
              return;
            }
            errorMessage = errorJson['message'] as String;
          } catch (_) {
            print(
                '❌ [UI-REGISTER] Could not parse error as JSON, using original message');
            // Si no es JSON, usar el mensaje original
          }

          print('❌ [UI-REGISTER] Showing error dialog: $errorMessage');
          await ErrorDialog.show(
            context,
            message: errorMessage,
            title: 'Error de Registro',
          );
          return;
        }

        // En el nuevo flujo: si no hay error y no está autenticado, significa registro exitoso
        if (!authState.isAuthenticated) {
          print(
              '✅ [UI-REGISTER] Registration successful (new flow), navigating to email verification');
          context.go('/verify-email?email=${Uri.encodeComponent(
              _emailController.text)}&fullName=${Uri.encodeComponent(
              _fullNameController.text)}');
          return;
        }

        // Flujo antiguo: si está autenticado, ir a home
        if (authState.isAuthenticated) {
          print(
              '✅ [UI-REGISTER] Registration successful (old flow), user authenticated, going to home');
          context.go('/home');
          return;
        }
      } catch (e) {
        print('❌ [UI-REGISTER] Exception caught in UI: $e');
        if (!mounted) return;

        String errorMessage = 'Error al registrar usuario';

        if (e.toString().contains('email ya está registrado')) {
          errorMessage =
          'Este email ya está registrado. Por favor usa otro email o inicia sesión.';
        } else if (e.toString().contains('conexión')) {
          errorMessage =
          'Error de conexión. Por favor verifica tu conexión a internet.';
        } else if (e.toString().contains('contraseña débil')) {
          errorMessage =
          'La contraseña es demasiado débil. Debe contener al menos 6 caracteres, una mayúscula y un número.';
        } else if (e.toString().contains('email inválido')) {
          errorMessage =
          'El email ingresado no es válido. Por favor verifica el formato.';
        } else if (e.toString().contains(
            '{"message":"El email ya está registrado"}')) {
          errorMessage =
          'Este email ya está registrado. Por favor usa otro email o inicia sesión.';
        }

        print(
            '❌ [UI-REGISTER] Showing error dialog for exception: $errorMessage');
        await ErrorDialog.show(
          context,
          message: errorMessage,
          title: 'Error de Registro',
        );
      }
    } else {
      print('❌ [UI-REGISTER] Form validation failed');
    }
  }

    @override
    Widget build(BuildContext context) {
      final authState = ref.watch(authStateProvider);
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final size = MediaQuery.of(context).size;
      print(
          '🔧 [REGISTER-DEBUG] Building RegisterScreen - keyboard height: $keyboardHeight');

      // Comentado: Esta lógica interfiere con el flujo de verificación de email
      // if (authState.isAuthenticated) {
      //   Future.microtask(() => context.go('/home'));
      // }
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              // Fondo principal
            Container(
            width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF0D1D35),
                    Color(0xFF073E6C),
                    Color(0xFF034E87),
                    Color(0xFF0D1D35),
                  ],
                ),
              ),
            ),

            // Luz roja inferior izquierda
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomLeft,
                  radius: 1.0,
                  colors: [
                    const Color(0xFFE6332F).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Luz roja superior derecha
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.0,
                  colors: [
                    const Color(0xFFE6332F).withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 1000),
                          child: Hero(
                            tag: 'logo',
                            child: SizedBox(
                              width: 170,
                              height: 180,
                              child: Center(
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/Container.png',
                                    height: 170,
                                    width: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Card del formulario
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 400),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white24,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.transparent,
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Título del formulario
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      'Crear Cuenta',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      'Completa tus datos para registrarte',
                                       style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Campo: Nombre completo
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _fullNameController,
                                      focusNode: _fullNameFocus,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      onTap: () {
                                        print('🔧 [REGISTER-DEBUG] FullName field tapped');
                                      },
                                      onChanged: (value) {
                                        print('🔧 [REGISTER-DEBUG] FullName changed: ${value.length} chars');
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Nombre Completo',
                                        labelStyle: GoogleFonts.inter(
                                          color: Colors.grey[600],
                                          fontSize: 16
                                        ),
                                        errorMaxLines: 2,
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 12,
                                        ),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppColors.primary,
                                        ),
                                        errorStyle: const TextStyle(color: Color(0xFF696969)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      textCapitalization: TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        print('🔧 [REGISTER-DEBUG] FullName submitted, moving to email');
                                        _emailFocus.requestFocus();
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingresa tu nombre completo *';
                                        }
                                        if (value.trim().split(' ').length < 2) {
                                          return 'Por favor ingresa tu nombre y apellido *';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Campo de email - CON FOCUS NODE
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      focusNode: _emailFocus,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      onTap: () {
                                        print('🔧 [REGISTER-DEBUG] Email field tapped');
                                      },
                                      onChanged: (value) {
                                        print('🔧 [REGISTER-DEBUG] Email changed: ${value.length} chars');
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: GoogleFonts.inter(
                                          color: Colors.grey[600],
                                          fontSize: 16
                                        ),
                                        errorStyle: const TextStyle(color: Color(0xFF696969)),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 12,
                                        ),
                                        errorMaxLines: 2,
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: AppColors.primary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      onFieldSubmitted: (_) {
                                        print('🔧 [REGISTER-DEBUG] Email submitted, moving to password');
                                        _passwordFocus.requestFocus();
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingresa tu email *';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Por favor ingresa un email válido *';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Campo de contraseña - CON FOCUS NODE
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocus,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      onTap: () {
                                        print('🔧 [REGISTER-DEBUG] Password field tapped');
                                      },
                                      onChanged: (value) {
                                        print('🔧 [REGISTER-DEBUG] Password changed: ${value.length} chars');
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Contraseña',
                                        labelStyle: GoogleFonts.inter(
                                          color: Colors.grey[600],
                                          fontSize: 16
                                        ),
                                        errorStyle: const TextStyle(color: Color(0xFF696969)),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 12,
                                        ),
                                        errorMaxLines: 2,
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: AppColors.primary,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.primary,
                                          ),
                                          onPressed: () {
                                            print('🔧 [REGISTER-DEBUG] Password visibility toggled');
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      obscureText: !_isPasswordVisible,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        print('🔧 [REGISTER-DEBUG] Password submitted, moving to confirm password');
                                        _confirmPasswordFocus.requestFocus();
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor ingresa tu contraseña *';
                                        }
                                        if (value.length < 6) {
                                          return 'La contraseña debe tener al menos 6 caracteres *';
                                        }
                                        if (!value.contains(RegExp(r'[A-Z]'))) {
                                          return 'La contraseña debe contener al menos\n una mayúscula *';
                                        }
                                        if (!value.contains(RegExp(r'[0-9]'))) {
                                          return 'La contraseña debe contener al menos un número *';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('Mínimo 6 caracteres', style: GoogleFonts.montserrat(fontSize: 12, color: const Color(0xFFDADADA))),
                                  ),
                                  // Campo de confirmar contraseña - CON FOCUS NODE
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      focusNode: _confirmPasswordFocus,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      onTap: () {
                                        print('🔧 [REGISTER-DEBUG] Confirm password field tapped');
                                      },
                                      onChanged: (value) {
                                        print('🔧 [REGISTER-DEBUG] Confirm password changed: ${value.length} chars');
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Confirmar Contraseña',
                                        labelStyle: GoogleFonts.inter(
                                          color: Colors.grey[600],
                                          fontSize: 16
                                        ),
                                        errorMaxLines: 2,
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 12,
                                        ),
                                        floatingLabelBehavior: FloatingLabelBehavior.never,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          color: AppColors.primary,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isConfirmPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.primary,
                                          ),
                                          onPressed: () {
                                            print('🔧 [REGISTER-DEBUG] Confirm password visibility toggled');
                                            setState(() {
                                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        errorStyle: const TextStyle(color: Color(0xFF696969)),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      obscureText: !_isConfirmPasswordVisible,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) {
                                        print('🔧 [REGISTER-DEBUG] Confirm password submitted, attempting register');
                                        _register();
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor confirma tu contraseña *';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Las contraseñas no coinciden *';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('Al registrarme, entiendo los Términos y condiciones y la Política de privacidad', style: GoogleFonts.montserrat(fontSize: 14, color: Color(0xFFDADADA))),
                                  ),
                                  const SizedBox(height: 14),

                                  // Botón "Crear Cuenta"
                                  Container(
                                    width: double.infinity,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFFFF1B21),
                                        Color(0xFFDD0E13),
                                        Color(0xFFBB0004),
                                      ]),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color(0xFFFF1B21),
                                            blurRadius: 20,      // intensidad
                                            offset: Offset(0, 7) // altura
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(7),

                                    ),
                                    child: ElevatedButton(
                                      onPressed: authState.isLoading ? null : _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        elevation: 6,
                                      ),
                                      child: authState.isLoading
                                          ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : Text(
                                        'Crear Cuenta',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Link "¿Ya tienes cuenta? Inicia sesión"
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '¿Ya tienes cuenta?',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFFCDCDCD),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            print('🔧 [REGISTER-DEBUG] Login button pressed');
                                            context.go('/login');
                                          },
                                          child: Text(
                                            'Inicia sesión',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFFAFDDFC),
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),


                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                            ),
          ),
        ]
          ),
          ),
        );
    }
}