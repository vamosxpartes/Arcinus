/// Defines the possible roles within the Arcinus application.
enum AppRole {
  superAdmin, // For platform administration
  propietario, // Owner of one or more academies
  colaborador, // Staff member with specific permissions
  atleta, // Athlete member of an academy
  padre, // Parent/Guardian linked to one or more athletes
  desconocido, // Default/Error state
} 