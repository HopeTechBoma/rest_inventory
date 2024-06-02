class BoissonModel {
  final String name;
  final String phoneNumber;
  final String productId; // Add productId property
  final String nbre_boissons;
  final String product_image;
  bool _isSelected; // Define _isSelected as private

  BoissonModel(this.name, this.phoneNumber, this.productId, this.nbre_boissons, this.product_image, this._isSelected);

  // Getter for isSelected
  bool get isSelected => _isSelected;

  // Setter for isSelected
  set isSelected(bool value) {
    _isSelected = value;
  }
  
}
