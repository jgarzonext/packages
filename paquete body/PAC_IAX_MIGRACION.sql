CREATE OR REPLACE PACKAGE BODY pac_iax_migracion AS
  /******************************************************************************
     NOMBRE:      pac_iax_migracion
     PROPÓSITO: Funciones para realizar la migracion de osiris a iAxis
  
     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        16/07/2019   OAS             1. Creación del package.
  
  ******************************************************************************/
  /*************************************************************************
     Consulta si la poliza existe en osiris
     param in pnpoliza    : Número de poliza
     param in psucursal   : codigo de la sucursal 3 digitos formato osiris
     param out mensajes   : mensajes de error
     return               : Respuesta para validar si existe la poliza 0 no existe, <> 0 existe
  *************************************************************************/
  FUNCTION f_consulta_poliza(pnpoliza IN VARCHAR2, psucursal IN NUMBER)
    RETURN NUMBER IS
  
    vnumerr  NUMBER(8);
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pnpoliza= ' || pnpoliza || ' psucursal= ' ||
                               psucursal;
    vobject  VARCHAR2(200) := 'PAC_IAX_MIGRACION.f_consulta_poliza';
  BEGIN
    -- Verificación de los parámetros
    IF pnpoliza IS NULL OR psucursal IS NULL THEN
      RAISE e_param_error;
    END IF;
  
    vnumerr := pac_md_migracion.f_consulta_poliza(pnpoliza, psucursal);
  
    RETURN vnumerr;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  end f_consulta_poliza;
END pac_iax_migracion;
/