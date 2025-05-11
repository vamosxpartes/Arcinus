import 'package:arcinus/core/sports/data/models/sport_model.dart';
import 'package:arcinus/core/sports/models/sport_characteristics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositorio para gestionar los deportes en Firestore
class SportsRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'sports';

  SportsRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtiene la referencia a la colección de deportes
  CollectionReference<Map<String, dynamic>> get sportsCollection => 
      _firestore.collection(_collectionPath);

  /// Inicializa la colección de deportes con todos los deportes soportados
  Future<void> initializeSportsCollection() async {
    final batch = _firestore.batch();
    final sports = SportModel.getAllSports();
    
    for (final sport in sports) {
      final docRef = sportsCollection.doc(sport.code);
      batch.set(docRef, sport.toJson(), SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  /// Obtiene todos los deportes
  Future<List<SportModel>> getAllSports() async {
    final snapshot = await sportsCollection.get();
    return snapshot.docs.map((doc) {
      return SportModel.fromJson(doc.data()).copyWith(id: doc.id);
    }).toList();
  }

  /// Obtiene un deporte por su código
  Future<SportModel?> getSportByCode(String sportCode) async {
    final docSnapshot = await sportsCollection.doc(sportCode).get();
    
    if (!docSnapshot.exists) return null;
    
    return SportModel.fromJson(docSnapshot.data()!)
        .copyWith(id: docSnapshot.id);
  }

  /// Obtiene las características de un deporte por su código
  Future<SportCharacteristics?> getSportCharacteristics(String sportCode) async {
    final sport = await getSportByCode(sportCode);
    return sport?.characteristics;
  }

  /// Actualiza un deporte
  Future<void> updateSport(SportModel sport) async {
    if (sport.id == null) {
      throw ArgumentError('El deporte debe tener un ID para actualizarlo');
    }
    
    await sportsCollection.doc(sport.id).update(sport.toJson());
  }
} 