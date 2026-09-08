import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<void> uploadRoutes() async {
    await db.child('routes').set({
      'route1': {
        'source': 'Vizianagaram',
        'destination': 'Visakhapatnam',
        'halts': {
          'halt1': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
          'halt2': {
            'name': 'Ayinada Junction',
            'latitude': 18.061556,
            'longitude': 83.393528,
          },
          'halt3': {
            'name': 'Dharmapuri Junction',
            'latitude': 18.046306,
            'longitude': 83.404667,
          },
          'halt4': {
            'name': 'Jonnada',
            'latitude': 18.025611,
            'longitude': 83.405278,
          },
          'halt5': {
            'name': 'Lendi College',
            'latitude': 18.021861,
            'longitude': 83.405556,
          },
          'halt6': {
            'name': 'Bodametlapalem',
            'latitude': 18.009083,
            'longitude': 83.408361,
          },
          'halt7': {
            'name': 'Raghu College',
            'latitude': 17.994444,
            'longitude': 83.413889,
          },
          'halt8': {
            'name': 'Rajapulova Junction',
            'latitude': 17.961250,
            'longitude': 83.419583,
          },
          'halt9': {
            'name': 'Avanthi College',
            'latitude': 17.942722,
            'longitude': 83.420472,
          },
          'halt10': {
            'name': 'Thagarapuvalasa',
            'latitude': 17.935639,
            'longitude': 83.422667,
          },
          'halt11': {
            'name': 'Anandapuram',
            'latitude': 17.894972,
            'longitude': 83.377139,
          },
          'halt12': {
            'name': 'Gambhiram',
            'latitude': 17.872889,
            'longitude': 83.370944,
          },
          'halt13': {
            'name': 'Madhurawada',
            'latitude': 17.822917,
            'longitude': 83.356667,
          },
          'halt14': {
            'name': 'YSR Stadium Junction',
            'latitude': 17.797333,
            'longitude': 83.353361,
          },
          'halt15': {
            'name': 'Visakhapatnam',
            'latitude': 17.724750,
            'longitude': 83.308472,
          },
        },
      },

      'route2': {
        'source': 'Vizianagaram',
        'destination': 'Cheepurupalli',
        'halts': {
          'halt1': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
          'halt2': {
            'name': 'Nellimarla',
            'latitude': 18.155917,
            'longitude': 83.447028,
          },
          'halt3': {
            'name': 'Gurla',
            'latitude': 18.211333,
            'longitude': 83.466528,
          },
          'halt4': {
            'name': 'Garividi',
            'latitude': 18.284722,
            'longitude': 83.538611,
          },
          'halt5': {
            'name': 'Cheepurupalli',
            'latitude': 18.310111,
            'longitude': 83.566389,
          },
        },
      },

      'route3': {
        'source': 'Vizianagaram',
        'destination': 'Gajapathinagaram',
        'halts': {
          'halt1': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
          'halt2': {
            'name': 'JNTU Junction',
            'latitude': 18.141972,
            'longitude': 83.349222,
          },
          'halt3': {
            'name': 'Gotlam',
            'latitude': 18.167056,
            'longitude': 83.376472,
          },
          'halt4': {
            'name': 'Gajapathinagaram',
            'latitude': 18.279972,
            'longitude': 83.338167,
          },
        },
      },

      'route4': {
        'source': 'Vizianagaram',
        'destination': 'Salur',
        'halts': {
          'halt1': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
          'halt2': {
            'name': 'Ramabhadrapuram',
            'latitude': 18.507500,
            'longitude': 83.604722,
          },
          'halt3': {
            'name': 'Salur',
            'latitude': 18.519444,
            'longitude': 83.202778,
          },
        },
      },

      'route5': {
        'source': 'Vizianagaram',
        'destination': 'S.Kota',
        'halts': {
          'halt1': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
          'halt2': {
            'name': 'Kothavalasa',
            'latitude': 17.888333,
            'longitude': 83.099444,
          },
          'halt3': {
            'name': 'Boddam',
            'latitude': 18.060278,
            'longitude': 83.144222,
          },
          'halt4': {
            'name': 'S.Kota',
            'latitude': 18.105000,
            'longitude': 83.135000,
          },
        },
      },

      'route6': {
        'source': 'Vizianagaram',
        'destination': 'S.Kota',
        'halts': {
          'halt1': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
          'halt2': {
            'name': 'Bheemasingi',
            'latitude': 18.045667,
            'longitude': 83.292778,
          },
          'halt3': {
            'name': 'Jami',
            'latitude': 18.051528,
            'longitude': 83.259639,
          },
          'halt4': {
            'name': 'S.Kota',
            'latitude': 18.105000,
            'longitude': 83.135000,
          },
        },
      },
      'route7': {
        'source': 'Visakhapatnam',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {
            'name': 'Visakhapatnam',
            'latitude': 17.724750,
            'longitude': 83.308472,
          },
          'halt2': {
            'name': 'YSR Stadium Junction',
            'latitude': 17.797333,
            'longitude': 83.353361,
          },
          'halt3': {
            'name': 'Madhurawada',
            'latitude': 17.822917,
            'longitude': 83.356667,
          },
          'halt4': {
            'name': 'Gambhiram',
            'latitude': 17.872889,
            'longitude': 83.370944,
          },
          'halt5': {
            'name': 'Anandapuram',
            'latitude': 17.894972,
            'longitude': 83.377139,
          },
          'halt6': {
            'name': 'Thagarapuvalasa',
            'latitude': 17.935639,
            'longitude': 83.422667,
          },
          'halt7': {
            'name': 'Avanthi College',
            'latitude': 17.942722,
            'longitude': 83.420472,
          },
          'halt8': {
            'name': 'Rajapulova Junction',
            'latitude': 17.961250,
            'longitude': 83.419583,
          },
          'halt9': {
            'name': 'Raghu College',
            'latitude': 17.994444,
            'longitude': 83.413889,
          },
          'halt10': {
            'name': 'Bodametlapalem',
            'latitude': 18.009083,
            'longitude': 83.408361,
          },
          'halt11': {
            'name': 'Lendi College',
            'latitude': 18.021861,
            'longitude': 83.405556,
          },
          'halt12': {
            'name': 'Jonnada',
            'latitude': 18.025611,
            'longitude': 83.405278,
          },
          'halt13': {
            'name': 'Dharmapuri Junction',
            'latitude': 18.046306,
            'longitude': 83.404667,
          },
          'halt14': {
            'name': 'Ayinada Junction',
            'latitude': 18.061556,
            'longitude': 83.393528,
          },
          'halt15': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
        },
      },

      'route8': {
        'source': 'Cheepurupalli',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {
            'name': 'Cheepurupalli',
            'latitude': 18.310111,
            'longitude': 83.566389,
          },
          'halt2': {
            'name': 'Garividi',
            'latitude': 18.284722,
            'longitude': 83.538611,
          },
          'halt3': {
            'name': 'Gurla',
            'latitude': 18.211333,
            'longitude': 83.466528,
          },
          'halt4': {
            'name': 'Nellimarla',
            'latitude': 18.155917,
            'longitude': 83.447028,
          },
          'halt5': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
        },
      },

      'route9': {
        'source': 'Gajapathinagaram',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {
            'name': 'Gajapathinagaram',
            'latitude': 18.279972,
            'longitude': 83.338167,
          },
          'halt2': {
            'name': 'Gotlam',
            'latitude': 18.167056,
            'longitude': 83.376472,
          },
          'halt3': {
            'name': 'JNTU Junction',
            'latitude': 18.141972,
            'longitude': 83.349222,
          },
          'halt4': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
        },
      },

      'route10': {
        'source': 'Salur',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {
            'name': 'Salur',
            'latitude': 18.519444,
            'longitude': 83.202778,
          },
          'halt2': {
            'name': 'Ramabhadrapuram',
            'latitude': 18.507500,
            'longitude': 83.604722,
          },
          'halt3': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
        },
      },
      'route11': {
        'source': 'S.Kota',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {
            'name': 'S.Kota',
            'latitude': 18.105000,
            'longitude': 83.135000,
          },
          'halt2': {
            'name': 'Boddam',
            'latitude': 18.060278,
            'longitude': 83.144222,
          },
          'halt3': {
            'name': 'Kothavalasa',
            'latitude': 17.888333,
            'longitude': 83.099444,
          },
          'halt4': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
        },
      },

      'route12': {
        'source': 'S.Kota',
        'destination': 'Vizianagaram',
        'halts': {
          'halt1': {
            'name': 'S.Kota',
            'latitude': 18.105000,
            'longitude': 83.135000,
          },
          'halt2': {
            'name': 'Jami',
            'latitude': 18.051528,
            'longitude': 83.259639,
          },
          'halt3': {
            'name': 'Bheemasingi',
            'latitude': 18.045667,
            'longitude': 83.292778,
          },
          'halt4': {
            'name': 'Vizianagaram',
            'latitude': 18.108444,
            'longitude': 83.398917,
          },
        },
      },
    });

    print('All routes uploaded successfully!');
  }
}