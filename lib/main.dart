import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importação condicional: evita que o dart:html quebre a compilação do APK
import 'eruda_stub.dart' if (dart.library.html) 'eruda_web.dart' as eruda;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    eruda.injectEruda();
  }

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(
      authFlowType: kIsWeb ? AuthFlowType.implicit : AuthFlowType.pkce,
    ),
  );

  runApp(const FabuliaApp());
}

final supabase = Supabase.instance.client;

class FabuliaApp extends StatelessWidget {
  const FabuliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FabuliA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9EAA),
          primary: const Color(0xFFFF9EAA),
          secondary: const Color(0xFFA2D2FF),
        ),
        textTheme: GoogleFonts.fredokaTextTheme(),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _recoverSession();

    supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _session = data.session;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _recoverSession() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      setState(() {
        _session = supabase.auth.currentSession;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF5E4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9EAA)),
        ),
      );
    }

    if (_session != null) {
      return const HomePage();
    }

    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha e-mail e senha.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no login: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe e-mail e senha.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'https://lucffernands07.github.io/fabulia_app/',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada! Verifique seu e-mail para confirmar.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        await supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'https://lucffernands07.github.io/fabulia_app/',
        );
      } else {
        // Login Nativo para Android (APK)
        const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

        final googleSignIn = GoogleSignIn(
          serverClientId: webClientId.isNotEmpty ? webClientId : null,
        );
        final googleUser = await googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;

        if (googleAuth?.idToken == null || googleAuth?.accessToken == null) {
          throw 'Não foi possível obter a autenticação do Google.';
        }

        await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth!.idToken!,
          accessToken: googleAuth.accessToken,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao logar com Google: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  size: 70,
                  color: Color(0xFFFF9EAA),
                ),
                const SizedBox(height: 10),
                Text(
                  'FabuliA',
                  style: GoogleFonts.fredoka(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A4E69),
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  ElevatedButton(
                    onPressed: _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9EAA),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _signUpWithEmail,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Criar Conta'),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OU'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 30),
                    label: const Text('Entrar com Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E4),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                size: 80,
                color: Color(0xFFFF9EAA),
              ),
              const SizedBox(height: 20),
              Text(
                'FabuliA',
                style: GoogleFonts.fredoka(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Histórias mágicas personalizadas',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  color: const Color(0xFF8D99AE),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'Criar Nova História',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9EAA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 30),
              TextButton.icon(
                onPressed: () async => await supabase.auth.signOut(),
                icon: const Icon(Icons.logout, color: Colors.grey),
                label: const Text(
                  'Sair da conta',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
