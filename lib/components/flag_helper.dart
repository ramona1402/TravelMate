import 'package:flutter/material.dart';

class FlagHelper {
  static Map<String, String> getFlagAssetMap() {
    return {
      'af': 'assets/flags/za.png', 
      'sq': 'assets/flags/al.png', 
      'am': 'assets/flags/et.png', 
      'ar': 'assets/flags/sa.png', 
      'hy': 'assets/flags/am.png', 
      'az': 'assets/flags/az.png', 
      'eu': 'assets/flags/es.png', 
      'be': 'assets/flags/by.png', 
      'bn': 'assets/flags/bd.png', 
      'bs': 'assets/flags/ba.png', 
      'bg': 'assets/flags/bg.png', 
      'ca': 'assets/flags/es.png', 
      'ceb': 'assets/flags/ph.png',
      'ny': 'assets/flags/mw.png',
      'zh-cn': 'assets/flags/cn.png', 
      'zh-tw': 'assets/flags/tw.png', 
      'co': 'assets/flags/fr.png', 
      'hr': 'assets/flags/hr.png', 
      'cs': 'assets/flags/cz.png', 
      'da': 'assets/flags/dk.png', 
      'nl': 'assets/flags/nl.png', 
      'en': 'assets/flags/us.png', 
      'eo': 'assets/flags/eo.png', 
      'et': 'assets/flags/ee.png', 
      'tl': 'assets/flags/ph.png', 
      'fi': 'assets/flags/fi.png', 
      'fr': 'assets/flags/fr.png', 
      'fy': 'assets/flags/nl.png', 
      'gl': 'assets/flags/es.png', 
      'ka': 'assets/flags/ge.png',
      'de': 'assets/flags/de.png',
      'el': 'assets/flags/gr.png',
      'gu': 'assets/flags/in.png',
      'ht': 'assets/flags/ht.png',
      'ha': 'assets/flags/ng.png',
      'haw': 'assets/flags/us.png',
      'iw': 'assets/flags/il.png',
      'hi': 'assets/flags/in.png',
      'hmn': 'assets/flags/cn.png',
      'hu': 'assets/flags/hu.png',
      'is': 'assets/flags/is.png',
      'ig': 'assets/flags/ng.png',
      'id': 'assets/flags/id.png',
      'ga': 'assets/flags/ie.png',
      'it': 'assets/flags/it.png',
      'ja': 'assets/flags/jp.png',
      'jw': 'assets/flags/id.png',
      'kn': 'assets/flags/in.png', 
      'kk': 'assets/flags/kz.png', 
      'km': 'assets/flags/kh.png', 
      'ko': 'assets/flags/kr.png', 
      'ku': 'assets/flags/iq.png', 
      'ky': 'assets/flags/kg.png', 
      'lo': 'assets/flags/la.png', 
      'la': 'assets/flags/va.png', 
      'lv': 'assets/flags/lv.png', 
      'lt': 'assets/flags/lt.png', 
      'lb': 'assets/flags/lu.png', 
      'mk': 'assets/flags/mk.png', 
      'mg': 'assets/flags/mg.png', 
      'ms': 'assets/flags/my.png', 
      'ml': 'assets/flags/in.png', 
      'mt': 'assets/flags/mt.png', 
      'mi': 'assets/flags/nz.png', 
      'mr': 'assets/flags/in.png', 
      'mn': 'assets/flags/mn.png', 
      'my': 'assets/flags/mm.png', 
      'ne': 'assets/flags/np.png', 
      'no': 'assets/flags/no.png', 
      'ps': 'assets/flags/af.png', 
      'fa': 'assets/flags/ir.png', 
      'pl': 'assets/flags/pl.png', 
      'pt': 'assets/flags/pt.png', 
      'pa': 'assets/flags/in.png', 
      'ro': 'assets/flags/ro.png', 
      'ru': 'assets/flags/ru.png', 
      'sm': 'assets/flags/ws.png', 
      'gd': 'assets/flags/gb.png', 
      'sr': 'assets/flags/rs.png', 
      'st': 'assets/flags/ls.png', 
      'sn': 'assets/flags/zw.png', 
      'sd': 'assets/flags/pk.png', 
      'si': 'assets/flags/lk.png', 
      'sk': 'assets/flags/sk.png', 
      'sl': 'assets/flags/si.png', 
      'so': 'assets/flags/so.png', 
      'es': 'assets/flags/es.png', 
      'su': 'assets/flags/id.png', 
      'sw': 'assets/flags/tz.png', 
      'sv': 'assets/flags/se.png', 
      'tg': 'assets/flags/tj.png', 
      'ta': 'assets/flags/in.png', 
      'te': 'assets/flags/in.png', 
      'th': 'assets/flags/th.png', 
      'tr': 'assets/flags/tr.png', 
      'uk': 'assets/flags/ua.png', 
      'ur': 'assets/flags/pk.png', 
      'uz': 'assets/flags/uz.png', 
      'ug': 'assets/flags/cn.png', 
      'vi': 'assets/flags/vn.png', 
      'cy': 'assets/flags/gb.png', 
      'xh': 'assets/flags/za.png', 
      'yi': 'assets/flags/il.png', 
      'yo': 'assets/flags/ng.png', 
      'zu': 'assets/flags/za.png', 
    };
  }

  static String getFlagAsset(String languageCode) {
    final flagMap = getFlagAssetMap();
    return flagMap[languageCode] ?? 'assets/flags/generic.png';
  }

  static Widget flag(String languageCode, {double size = 24}) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          getFlagAsset(languageCode),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/flags/generic.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag,
                    size: size * 0.6,
                    color: Colors.grey[600],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
  static Widget flagAvatar(String languageCode, {double radius = 12}) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: AssetImage(getFlagAsset(languageCode)),
      onBackgroundImageError: (exception, stackTrace) {
      },
      child: Image.asset(
        getFlagAsset(languageCode),
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/flags/generic.png',
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag,
                  size: radius,
                  color: Colors.grey[600],
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget flagImage(String languageCode, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      getFlagAsset(languageCode),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/flags/generic.png',
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: Icon(
                Icons.flag,
                size: (width != null && height != null) ? (width < height ? width : height) * 0.6 : 24,
                color: Colors.grey[600],
              ),
            );
          },
        );
      },
    );
  }
}
