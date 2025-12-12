import 'package:bienestar_integral_app/core/router/routes.dart';
import 'package:bienestar_integral_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bienestar_integral_app/features/home/presentation/widgets/drawer_custom_header.dart';
import 'package:bienestar_integral_app/features/home/presentation/widgets/drawer_logout_button.dart';
import 'package:bienestar_integral_app/features/home/presentation/widgets/drawer_menu_item.dart';
// IMPORTANTE: Asegúrate de que estos imports apunten a donde guardaste los archivos
import 'package:bienestar_integral_app/features/settings/presentation/widgets/info_contents.dart';
import 'package:bienestar_integral_app/features/settings/presentation/widgets/info_modal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const DrawerCustomHeader(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  DrawerMenuItem(
                    icon: Icons.home_filled,
                    text: 'Inicio',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.edit,
                    text: 'Editar perfil',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.editProfilePath);
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.event_note,
                    text: 'Mis eventos',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.myEventsPath);
                    },
                  ),
                  DrawerMenuItem(
                    icon: Icons.settings,
                    text: 'Configuración',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.settingsPath);
                    },
                  ),

                  // Divisor visual
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(color: colorScheme.outline.withOpacity(0.2)),
                  ),

                  DrawerMenuItem(
                    icon: Icons.help_outline,
                    text: 'Ayuda y soporte',
                    onTap: () {
                      Navigator.pop(context);

                      InfoModal.show(
                        context,
                        title: 'Ayuda y Soporte',
                        content: InfoContents.helpAndSupport(context),
                      );
                    },
                  ),
                ],
              ),
            ),

            DrawerLogoutButton(
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}