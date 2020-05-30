--------------------------------------------------------
--  DDL for Package PAC_IAX_ESTCESIONESREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_ESTCESIONESREA" IS
   /****************************************************************************
       NOMBRE:     PAC_MD_ESTCESIONESREA
       PROP¿SITO:  Cesiones Manuales de Reaseguro

       REVISIONES:
       Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  -------- ------------------------------------
      1.0        07/09/2015   XXX     1. Creaci¿n del package.
    ****************************************************************************/
   FUNCTION f_del_estcesionesrea(
      pscesrea NUMBER DEFAULT -1,
      pssegpol NUMBER DEFAULT -1,
      psseguro NUMBER DEFAULT -1,
      mensajes OUT t_iax_mensajes)
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
      picomext estcesionesrea.icomext%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-------------------------------------------------------------------
-- f_get_estcesionesrea, f_get_estcesionrea
-------------------------------------------------------------------
   FUNCTION f_get_estcesionrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pcgenera number default -1,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_estcesionesrea;

   FUNCTION f_get_estcesionesrea(psseguro NUMBER, pcgenera number, mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea;

-------------------------------------------------------------------
-- f_get_estcesionesreasinies, f_get_estcesionreasinies
-------------------------------------------------------------------
   FUNCTION f_get_estcesionreasinies(
      pnsinies estcesionesrea.nsinies%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_estcesionesrea;

   FUNCTION f_get_estcesionesreasinies(
      pnsinies estcesionesrea.nsinies%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea;

-------------------------------------------------------------------
-- f_get_estcesionesreapolizas, f_get_estcesionesreapoliza
-------------------------------------------------------------------
   FUNCTION f_get_estcesionreapolizas(
      pnpoliza estcesionesrea.npoliza%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_estcesionesrea;

   --INI - AXIS 4105 - 05/06/2019 - AABG - SE AGREGA NUEVO PARAMETRO MOVIMIENTO
   FUNCTION f_get_estcesionesreapolizas(
      pnpoliza estcesionesrea.npoliza%TYPE,
      pcgenera number,
      pnmovimi NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea;
    --FIN - AXIS 4105 - 05/06/2019 - AABG - SE AGREGA NUEVO PARAMETRO MOVIMIENTO  

-------------------------------------------------------------------
-- f_get_estcesionesreacum
-------------------------------------------------------------------
   FUNCTION f_get_estcesionesreacum(pscumulo IN NUMBER, pcgenera number, mensajes OUT t_iax_mensajes)
      RETURN t_iax_estcesionesrea;

-------------------------------------------------------------------
-- f_get_sim_estcesionesrea (Bot¿n simulaci¿n)
-------------------------------------------------------------------
   FUNCTION f_get_sim_estcesionesrea(psseguro NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_sim_estcesionesrea;

   FUNCTION f_get_reaseguro_xl(psseguro IN seguros.sseguro%TYPE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-------------------------------------------------------------------
-- f_update_estcesionesrea
-------------------------------------------------------------------
   FUNCTION f_update_estcesionesrea_tramo(
      pscesrea estcesionesrea.scesrea%TYPE,
      pctramo estcesionesrea.ctramo%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_update_estcesionesrea_fechas(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE,   -- Nueva fecha de vencimiento
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION validafechas(
      pscesrea estcesionesrea.scesrea%TYPE,   -- Primary key en estcesionesrea
      pssegpol estcesionesrea.ssegpol%TYPE,   -- Identificador del seguro
      pcgarant estcesionesrea.cgarant%TYPE,   -- Garant¿a
      pfefecto DATE,   -- Nueva fecha de efecto
      pfvencimiento DATE,   -- Nueva fecha de vencimiento
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_update_estcesionesrea(
      pscesrea estcesionesrea.scesrea%TYPE,
      pssegpol estcesionesrea.ssegpol%TYPE,
      picesion estcesionesrea.icesion%TYPE,
      picapces estcesionesrea.icapces%TYPE,
      ppcesion estcesionesrea.pcesion%TYPE,
      mensajes OUT t_iax_mensajes)
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
      porigen NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION compruebaporcenfacultativo(
      pscesrea estcesionesrea.scesrea%TYPE,
      pcesion estcesionesrea.pcesion%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION compruebaporcentajes(
      pssegpol estcesionesrea.ssegpol%TYPE,
      pcgarant estcesionesrea.cgarant%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_cabfacul(pssegpol NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_totalesestcesionrea(
      psseguro IN NUMBER,
      ptotporcesion OUT NUMBER,
      ptotcapital OUT NUMBER,
      ptotcesion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION traspaso_inf_cesionesreatoest(
      pssegpol NUMBER,
      pnsinies NUMBER,
      pcgenera number,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION traspaso_inf_esttocesionesrea(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION simulacion_cierre_proporcional(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION simulacion_cierre_xl(
      psseguro IN NUMBER,
      pcerror OUT NUMBER,
      psproces OUT NUMBER,
      pfproces OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_estado_de_poliza(
      psseguro NUMBER,
      pnpoliza NUMBER,
      pestado OUT VARCHAR2,
      pfestado OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Recupera la informaci¿n de valores seg¿n la clave
      param in clave     : clave a recuperar detalles
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_detvalores_tramos(
      psseguro IN seguros.sseguro%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_valida_tramos(pssegpol NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_estcesionesrea;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESTCESIONESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESTCESIONESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ESTCESIONESREA" TO "PROGRAMADORESCSI";
