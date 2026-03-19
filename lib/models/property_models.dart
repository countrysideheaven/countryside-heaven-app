class Fraction {
  final String id;
  String? ownerId; 

  Fraction({required this.id, this.ownerId});
}

class Unit {
  final String id;
  String name; 
  double fractionPrice;
  final List<Fraction> fractions;

  Unit({
    required this.id,
    required this.name,
    required this.fractionPrice,
    required this.fractions,
  });

  int get availableFractions => fractions.where((f) => f.ownerId == null).length;
}

class Property {
  final String id;
  String name; 
  String location; 
  final List<Unit> units;

  Property({
    required this.id,
    required this.name,
    required this.location,
    required this.units,
  });
}

class UserDocument {
  final String id;
  final String userId;
  final String fileName;
  String status; 

  UserDocument({required this.id, required this.userId, required this.fileName, this.status = 'pending'});
}

class Booking {
  final String id;
  // We store BOTH the unique ID (for logic) and the Name (for the UI)
  final String unitId;
  final String? unitName; 
  final String fractionId;
  final String? fractionName;
  final String userId;
  final String? userName;
  
  final DateTime startDate;
  final DateTime endDate;
  final String type; 
  final bool isOutsideBooking; 
  final String? guestName; 

  Booking({
    required this.id,
    required this.unitId,
    this.unitName,
    required this.fractionId,
    this.fractionName,
    required this.userId,
    this.userName,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.isOutsideBooking = false,
    this.guestName,
  });
}