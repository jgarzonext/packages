--------------------------------------------------------
--  DDL for Package PAC_MD_ESTCESIONESREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_ESTCESIONESREA" IS
   /****************************************************************************
       NOMBRE:     PAC_MD_ESTCESIONESREA
       PROP¿SITO:  Cesiones Manuales de Reaseguro

       REVISIONES:
       Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  -------- ------------------------------------
      1.0        07/09/2015   XXX     1. Creaci¿n del package.
    ****************************************************************************/
   TYPE t_valores IS RECORD(
      porcesion      NUMBER,
      totcesion      NUMBER,
      capital        NUMBER,
      totcapital     NUMBER,
      icesion        NUMBER,
      tcesion        NUMBER
   );

   gempresa       NUMBER;
   gidioma        NUMBER;
   -- C¿digos de AXIS_LITERALES
   --
   ok    CONSTANT NUMBER := 0;
   faltan_parametros CONSTANT NUMBER := 103135;
   campo_obligatorio CONSTANT NUMBER := 1000165;
   error_no_controlado CONSTANT NUMBER := 140999;
   seguro_no_existe CONSTANT NUMBER := 103286;
   no_se_encontraron_datos CONSTANT NUMBER := 120135;
   no_se_actualizaron_datos CONSTANT NUMBER := 9908453;

   FUNCTION f_del_estcesionesrea(
      pscesrea NUMBER DEFAULT -1,
      pssegpol NUMBER DEFAULT -1,
      psseguro NUMBER DEFAULT -1)
      RETURN NUMBER;

   FUNCTION f_set_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pncesion estcesionesrea.ncesion%TYPE,
      picesion estcesionesrea.icesion%TYPE,
      picapces estcesionesrea.icapces%TYPE,
      psseguro estcesionesrea.sseguro%TYPE,
      pssegpol estcesionesrea.ssegpol%TYPE,
      pnpoliza estcesionesrea.npoliza%TYPE,
      pncertif estcesionesrea.ncertif%TYPE,
      pnversio estcesionesrea.nversio%TYPE,
      pscontra estcesionesrea.scontra%TYPE,
      pctramo estcesionesrea.ctramo%TYPE,
      psfacult estcesionesrea.sfacult%TYPE,
      pnriesgo estcesionesrea.nriesgo%TYPE,
      picomisi estcesionesrea.icomisi%TYPE,
      pscumulo estcesionesrea.scumulo%TYPE,
      pgarant estcesionesrea.cgarant%TYPE,
      pspleno estcesionesrea.spleno%TYPE,
      pnsinies estcesionesrea.nsinies%TYPE,
      pfefecto estcesionesrea.fefecto%TYPE,
      pfvencim estcesionesrea.fvencim%TYPE,
      pfcontab estcesionesrea.fcontab%TYPE,
      ppcesion estcesionesrea.pcesion%TYPE,
      psproces estcesionesrea.sproces%TYPE,
      pcgenera estcesionesrea.cgenera%TYPE,
      pfgenera estcesionesrea.fgenera%TYPE,
      pfregula estcesionesrea.fregula%TYPE,
      pfanulac estcesionesrea.fanulac%TYPE,
      pnmovimi estcesionesrea.nmovimi%TYPE,
      psidepag estcesionesrea.sidepag%TYPE,
      pipritarrea estcesionesrea.ipritarrea%TYPE,
      ppsobreprima estcesionesrea.psobreprima%TYPE,
      pcdetces estcesionesrea.cdetces%TYPE,
      pipleno estcesionesrea.ipleno%TYPE,
      picapaci estcesionesrea.icapaci%TYPE,
      nmovigen estcesionesrea.nmovigen%TYPE,
      piextrap estcesionesrea.iextrap%TYPE,
      iextrea estcesionesrea.iextrea%TYPE,
      pnreemb estcesionesrea.nreemb%TYPE,
      pnfact estcesionesrea.nfact%TYPE,
      pnlinea estcesionesrea.nlinea%TYPE,
      pitarifrea estcesionesrea.itarifrea%TYPE,
      picomext estcesionesrea.icomext%TYPE)
      RETURN NUMBER;
	  
 --INI - AXIS 4105 - 05/06/2019 - AABG - PROCEDIMIENTO PARA OBTENER LAS CESIONES DE UNA POLIZA MEDIANTE EL MOVIMIENTO
    FUNCTION f_get_estcesionesreamovimiento(psfield VARCHAR2, pnvalue NUMBER, pcgenera IN number default -1, pnmovimi NUMBER)
      RETURN t_iax_estcesionesrea;
      
    FUNCTION f_get_estcesionesreamovpol(pnpoliza NUMBER, pcgenera number, pnmovimi NUMBER)
      RETURN t_iax_estcesionesrea;  
    --FIN - AXIS 4105 - 05/06/2019 - AABG - PROCEDIMIENTO PARA OBTENER LAS CESIONES DE UNA POLIZA MEDIANTE EL MOVIMIENTO  	  

-------------------------------------------------------------------
-- f_get_estcesionesrea, f_get_estcesionrea
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesrea(psseguro NUMBER, pcgenera number default -1)
      RETURN t_iax_estcesionesrea;

   FUNCTION f_get_estcesionrea(psfield VARCHAR2, pnvalue NUMBER, pcgenera IN NUMBER)
      RETURN ob_iax_estcesionesrea;

   FUNCTION f_get_estcesionrea(pscesrea estcesionesrea.scesrea%TYPE, pcgenera number)
      RETURN ob_iax_estcesionesrea;

-------------------------------------------------------------------
-- f_get_estcesionesreasinies, f_get_estcesionreasinies
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesreasinies(pnsinies estcesionesrea.nsinies%TYPE)
      RETURN t_iax_estcesionesrea;

   FUNCTION f_get_estcesionreasinies(pnsinies estcesionesrea.nsinies%TYPE)
      RETURN ob_iax_estcesionesrea;

-------------------------------------------------------------------
-- f_get_estcesionesreacum
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesreacum(pscumulo IN NUMBER, pcgenera number)
      RETURN t_iax_estcesionesrea;

-------------------------------------------------------------------
-- f_get_estcesionesreapolizas, f_get_estcesionesreapoliza
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesreapolizas(pnpoliza NUMBER, pcgenera number)
      RETURN t_iax_estcesionesrea;

   FUNCTION f_get_estcesionreapoliza(pnpoliza estcesionesrea.npoliza%TYPE)
      RETURN ob_iax_estcesionesrea;

-------------------------------------------------------------------
-- f_get_sim_estcesionesrea (Bot¿n simulaci¿n)
-------------------------------------------------------------------
   FUNCTION f_get_sim_estcesionesrea(psseguro NUMBER)
      RETURN t_iax_sim_estcesionesrea;

   FUNCTION f_get_reaseguro_xl(psseguro IN seguros.sseguro%TYPE)
      RETURN NUMBER;

-------------------------------------------------------------------
-- f_update_estcesionesrea
-------------------------------------------------------------------
   FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pctramo estcesionesrea.ctramo%TYPE)
      RETURN NUMBER;

   FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE)   -- Nueva fecha de vencimiento
      RETURN NUMBER;

   FUNCTION validafechas(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE)   -- Nueva fecha de vencimiento
      RETURN NUMBER;

   FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pssegpol estcesionesrea.ssegpol%TYPE,
      picesion estcesionesrea.icesion%TYPE,
      picapces estcesionesrea.icapces%TYPE,
      ppcesion estcesionesrea.pcesion%TYPE)
      RETURN NUMBER;

   FUNCTION setnuevotramocesion(
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE,   -- Nueva fecha de vencimiento
      psseguro estcesionesrea.sseguro%TYPE,   -- Identificador del seguro
      pnmovimi NUMBER,   -- Identificador del movimiento
      psproces NUMBER,   -- Identificador del proceso
      pmoneda monedas.cmoneda%TYPE,
      pnpoliza NUMBER,
      pncertif NUMBER,
      porigen NUMBER)
      RETURN NUMBER;

   FUNCTION compruebaporcenfacultativo(
      pscesrea estcesionesrea.scesrea%TYPE,
      pcesion estcesionesrea.pcesion%TYPE)
      RETURN NUMBER;

   FUNCTION compruebaporcentajes(
      pssegpol estcesionesrea.sseguro%TYPE,
      pcgarant estcesionesrea.cgarant%TYPE)
      RETURN NUMBER;

   FUNCTION f_cabfacul(pssegpol NUMBER)
      RETURN NUMBER;

   FUNCTION f_anular(
      psproces NUMBER,   -- Identificador de proceso que genera la anulaci¿n
      psseguro NUMBER,
      pfinici DATE,   -- Fecha a partir de la cual se retroceder¿n cesiones
      pmotiu NUMBER,   -- Motivo del retroceso ( 6,7,8)
      pmoneda NUMBER,   -- Moneda (1-Euros,2-Pesetas)
      pnmovigen NUMBER DEFAULT NULL,
      pfdatagen DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   FUNCTION f_get_totalesestcesionrea(
      psseguro IN NUMBER,
      ptotporcesion OUT NUMBER,
      ptotcapital OUT NUMBER,
      ptotcesion OUT NUMBER)
      RETURN NUMBER;

   PROCEDURE traspaso_inf_cesionesreatoest(
      pssegpol NUMBER,
      psproces NUMBER,
      pmoneda NUMBER,
      pnsinies NUMBER,
      pcgenera number);

   PROCEDURE traspaso_inf_esttocesionesrea(
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pmoneda IN NUMBER,
      pmensaje OUT VARCHAR2); --OJSO

   PROCEDURE simulacion_cierre_proporcional(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   PROCEDURE simulacion_cierre_xl(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE);

   FUNCTION f_consulta_ces_man(
      pnpoliza IN seguros.npoliza%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pnrecibo IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_garant_est(
      pssegpol estcesionesrea.sseguro%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la informaci?n de valores seg?n la clave
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalores_tramos(
      psseguro IN seguros.sseguro%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_valida_tramos(pssegpol NUMBER)
      RETURN NUMBER;

   PROCEDURE DEBUG(psfield VARCHAR2, pnvalue NUMBER, pbtodos BOOLEAN := FALSE);
END pac_md_estcesionesrea;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ESTCESIONESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ESTCESIONESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ESTCESIONESREA" TO "PROGRAMADORESCSI";
