import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  group('Auth form validations', () {
    group('Email validation', () {
      test('debería rechazar email vacío (required)', () {
        // Arrange
        final control = FormControl<String>(validators: [Validators.required]);
        
        // Act
        control.value = '';
        
        // Assert
        expect(control.valid, false);
        expect(control.hasError('required'), true);
      });
      
      test('debería rechazar email con formato inválido', () {
        // Arrange
        final control = FormControl<String>(validators: [Validators.email]);
        
        // Act
        control.value = 'correo-invalido';
        
        // Assert
        expect(control.valid, false);
        expect(control.hasError('email'), true);
      });
      
      test('debería aceptar email con formato válido', () {
        // Arrange
        final control = FormControl<String>(validators: [Validators.email]);
        
        // Act
        control.value = 'usuario@dominio.com';
        
        // Assert
        expect(control.valid, true);
      });
    });
    
    group('Password validation', () {
      test('debería rechazar contraseña vacía (required)', () {
        // Arrange
        final control = FormControl<String>(validators: [Validators.required]);
        
        // Act
        control.value = '';
        
        // Assert
        expect(control.valid, false);
        expect(control.hasError('required'), true);
      });
      
      test('debería rechazar contraseña menor a 6 caracteres', () {
        // Arrange
        final control = FormControl<String>(validators: [Validators.minLength(6)]);
        
        // Act
        control.value = '12345';
        
        // Assert
        expect(control.valid, false);
        expect(control.hasError('minLength'), true);
      });
      
      test('debería aceptar contraseña de 6 o más caracteres', () {
        // Arrange
        final control = FormControl<String>(validators: [Validators.minLength(6)]);
        
        // Act
        control.value = '123456';
        
        // Assert
        expect(control.valid, true);
      });
    });
    
    group('Confirmación de contraseña', () {
      test('debería rechazar confirmación que no coincide con contraseña', () {
        // Arrange
        final form = FormGroup({
          'password': FormControl<String>(value: 'password123'),
          'confirmPassword': FormControl<String>(),
        }, validators: [
          Validators.mustMatch('password', 'confirmPassword'),
        ]);
        
        // Act
        form.control('confirmPassword').value = 'diferente123';
        
        // Assert
        expect(form.control('confirmPassword').hasError('mustMatch'), true);
      });
      
      test('debería aceptar confirmación que coincide con contraseña', () {
        // Arrange
        final form = FormGroup({
          'password': FormControl<String>(value: 'password123'),
          'confirmPassword': FormControl<String>(),
        }, validators: [
          Validators.mustMatch('password', 'confirmPassword'),
        ]);
        
        // Act
        form.control('confirmPassword').value = 'password123';
        
        // Assert
        expect(form.control('confirmPassword').hasError('mustMatch'), false);
      });
    });
    
    group('Login form validation', () {
      test('login form debería ser inválido cuando campos están vacíos', () {
        // Arrange
        final form = FormGroup({
          'email': FormControl<String>(validators: [Validators.required, Validators.email]),
          'password': FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
        });
        
        // Act & Assert
        expect(form.valid, false);
      });
      
      test('login form debería ser válido cuando campos tienen datos correctos', () {
        // Arrange
        final form = FormGroup({
          'email': FormControl<String>(validators: [Validators.required, Validators.email]),
          'password': FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
        });
        
        // Act
        form.control('email').value = 'usuario@dominio.com';
        form.control('password').value = 'password123';
        
        // Assert
        expect(form.valid, true);
      });
    });
    
    group('Register form validation', () {
      test('register form debería ser inválido cuando campos están vacíos', () {
        // Arrange
        final form = FormGroup({
          'email': FormControl<String>(validators: [Validators.required, Validators.email]),
          'password': FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
          'confirmPassword': FormControl<String>(validators: [Validators.required]),
          'displayName': FormControl<String>(validators: [Validators.required]),
          'lastName': FormControl<String>(validators: [Validators.required]),
        }, validators: [
          Validators.mustMatch('password', 'confirmPassword'),
        ]);
        
        // Act & Assert
        expect(form.valid, false);
      });
      
      test('register form debería ser válido cuando campos tienen datos correctos', () {
        // Arrange
        final form = FormGroup({
          'email': FormControl<String>(validators: [Validators.required, Validators.email]),
          'password': FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
          'confirmPassword': FormControl<String>(validators: [Validators.required]),
          'displayName': FormControl<String>(validators: [Validators.required]),
          'lastName': FormControl<String>(validators: [Validators.required]),
        }, validators: [
          Validators.mustMatch('password', 'confirmPassword'),
        ]);
        
        // Act
        form.control('email').value = 'usuario@dominio.com';
        form.control('password').value = 'password123';
        form.control('confirmPassword').value = 'password123';
        form.control('displayName').value = 'Usuario';
        form.control('lastName').value = 'Apellido';
        
        // Assert
        expect(form.valid, true);
      });
    });
  });
} 