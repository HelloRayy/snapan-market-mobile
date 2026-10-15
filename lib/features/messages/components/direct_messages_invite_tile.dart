import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// "Undang Teman SMKN 8" action tile matching iOS pen.dev specs.
class DirectMessagesInviteTile extends StatelessWidget {
  final VoidCallback onTap;

  const DirectMessagesInviteTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.adaptiveCanvas(context),
      child: InkWell(
        onTap: onTap,
        highlightColor: AppColors.adaptiveSurfaceElevated(context),
        splashColor: AppColors.adaptiveSurfaceElevated(context),
        child: Container(
          height: 72.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.person_badge_plus,
                      color: Color(0xFF008BFF),
                      size: 24.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Undang Teman SMKN 8',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.adaptiveText(context),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 16.0,
                color: AppColors.adaptiveMuted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
