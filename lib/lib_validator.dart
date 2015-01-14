import 'dart:html';
// import 'package:polymer/polymer.dart';

Map<String, ValidationRule> _validationRulesLibrary = {};

void registerValidationRule(String name, ValidationRule rule) {
  _validationRulesLibrary[name] = rule;
}

/**
 */
class Validator {

  List<ValidationError> validateTree(Element root) {
    return _validateTreeImpl(root, []);
  }

  List<ValidationError> _validateTreeImpl(Element element, List<ValidationError> errors) {
    if (element is ValidationElement) {
      return (element as ValidationElement).validate();
    } else {
      validateDomElement(element, errors);


    }
    return errors;
  }

  validateDomElement(Element element, List errors) {
    String rules = element.getAttribute("ma-validation");
    if (rules != null) {
      Map<String, List<String>> validationRules = {};
      rules.split(";").forEach((rule) {
        if (rule.contains("=")) {
          List<String> parts = rule.split("=");
          validationRules[parts[0]] = parts[1].split(",");
        } else {
          validationRules[rule] = [];
        }
      });
      Object value = getElementValue(element);

    }
    return errors;
  }

  Object getElementValue(Element element) {
    if (element is InputElement) {
      return (element as InputElement).value;
    }
    /*
    FormElement f;

    InputElement i;

    i.validity = ValidityState.
    */
  }

/*
  <ma-input type="text" value="{{applicant['name']}}" label="Jméno a příjmení" class="input-name"
            validation="required;min=5;max=100" on-form-state-changed="{{updateFormState}}"></ma-input>

  <ma-input type="text" value="{{applicant['phone']}}" label="Telefon" class="input-phone"
            validation="required;min=9;max=20;regexp=^\+?[0-9 ]+$,Tohle nevypadá jako telefonní číslo" on-form-state-changed="{{updateFormState}}"></ma-input>

  <ma-input type="email" value="{{applicant['email']}}" label="E-mail" class="input-email"
            validation="required;min=5;max=100;email" on-form-state-changed="{{updateFormState}}"></ma-input>

  <ma-input type="textarea" value="{{applicant['message']}}" label="Vzkaz" class="input-message"
            validation="max=500" on-form-state-changed="{{updateFormState}}"></ma-input>
   */


}

class ValidationError {

  String messageKey;
  List messageParams;

  ValidationError(this.messageKey, [this.messageParams]);

}

abstract class ValidationElement {

  List<ValidationError> validate();

}


abstract class ValidationRule<T> {

  ValidationError validate(T value, [List<String> params, String errorMessageKey]);

}

class RequiredValidationRule extends ValidationRule<String> {

  ValidationError validate(String value, [List<String> params, String errorMessageKey]) {
    if (value == null || value.isEmpty) {
      return new ValidationError(errorMessageKey != null ? errorMessageKey : "validator.required", params);
    }

    return null;
  }

}

class MinValidationRule extends ValidationRule<String> {

  ValidationError validate(String value, [List<String> params, String errorMessageKey]) {
    int min = int.parse(params[0]);
    if (value != null && value.length < min) {
      return new ValidationError(errorMessageKey != null ? errorMessageKey : "validator.min", params);
    }
    return null;
  }

}

class MaxValidationRule extends ValidationRule<String> {

  ValidationError validate(String value, [List<String> params, String errorMessageKey]) {
    int max = int.parse(params[0]);
    if (value != null && value.length > max) {
      return new ValidationError(errorMessageKey != null ? errorMessageKey : "validator.max", params);
    }
    return null;
  }

}

class RegExpValidationRule extends ValidationRule<String> {

  ValidationError validate(String value, [List<String> params, String errorMessageKey]) {
    RegExp exp = new RegExp(params[0]);
    if (value != null && exp.allMatches(value).isEmpty) {
      return new ValidationError(errorMessageKey != null ? errorMessageKey : "validator.regexp", params);
    }
    return null;
  }

}

class EmailValidationRule extends ValidationRule<String> {

  static RegExp exp = new RegExp("^[a-zA-Z0-9._\\-+~]+@[a-zA-Z0-9._\\-+~]+\\.[a-z]{2,6}\$");

  ValidationError validate(String value, [List<String> params, String errorMessageKey]) {
    if (value != null && exp.allMatches(value).isEmpty) {
      return new ValidationError(errorMessageKey != null ? errorMessageKey : "validator.email", params);
    }
    return null;
  }

}
