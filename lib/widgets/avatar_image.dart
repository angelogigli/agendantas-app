import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class AvatarImage extends StatefulWidget {
  final String? foto;
  final String? nomeclown;
  final double size;

  const AvatarImage({
    super.key,
    this.foto,
    this.nomeclown,
    this.size = 60,
  });

  @override
  State<AvatarImage> createState() => _AvatarImageState();
}

class _AvatarImageState extends State<AvatarImage> {
  bool _avatarFailed = false;
  bool _photoFailed = false;

  String get _initials {
    if (widget.nomeclown != null && widget.nomeclown!.isNotEmpty) {
      return widget.nomeclown![0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    // Se entrambi falliti, mostra iniziale
    if (_avatarFailed && _photoFailed) {
      return _buildInitials();
    }

    // Se avatar fallito o non presente, prova photo/nomeclown.jpg
    if (_avatarFailed || widget.foto == null || widget.foto!.isEmpty) {
      if (widget.nomeclown != null && widget.nomeclown!.isNotEmpty && !_photoFailed) {
        return ClipOval(
          child: Image.network(
            '${ApiService.photoUrl}${widget.nomeclown}.jpg',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _photoFailed = true);
              });
              return _buildInitials();
            },
          ),
        );
      }
      return _buildInitials();
    }

    // Prova prima avatar/foto
    return ClipOval(
      child: Image.network(
        '${ApiService.avatarUrl}${widget.foto}',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _avatarFailed = true);
          });
          return _buildInitials();
        },
      ),
    );
  }

  Widget _buildInitials() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
