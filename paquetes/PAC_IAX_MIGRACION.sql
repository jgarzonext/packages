CREATE OR REPLACE PACKAGE pac_iax_migracion IS
  /******************************************************************************
     NOMBRE:      pac_iax_migracion
     PROPÓSITO: Funciones para realizar la migracion de osiris a iAxis
  
     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        16/07/2019   OAS             1. Creación del package.
  
  ******************************************************************************/
  e_object_error EXCEPTION;
  e_param_error  EXCEPTION;
  /*************************************************************************
     Consulta si la poliza existe en osiris
     param in pnpoliza    : Número de poliza
     param in psucursal   : codigo de la sucursal 3 digitos formato osiris
     param out mensajes   : mensajes de error
     return               : Respuesta para validar si existe la poliza 0 no existe, <> 0 existe
  *************************************************************************/
  FUNCTION f_consulta_poliza(pnpoliza IN VARCHAR2, psucursal IN NUMBER)
    RETURN NUMBER;

END pac_iax_migracion;
/