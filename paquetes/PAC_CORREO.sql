CREATE OR REPLACE PACKAGE pac_correo AS
/******************************************************************************
     NOMBRE:     PAC_CORREO
     PROPÓSITO:  Package para gestionar el correo

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        07/09/2011   JMF               1. 0018967 LCOL_T005 - Listas restringidas validaciones y controles
     2.0        17/07/2012   JGR               2. 0022753: MDP_A001-Cierre de remesa
     3.0        05/02/2013  AMJ               3 0025910: LCOL: Enviament de correu en el proc?s de liquidaci?
     4.0       01/03/2013    FAC              7. 0026209: LCOL_T010-LCOL - Soluci?n definitiva ejecuci?n de cartera desde pantalla
     5.0        02/09/2013   FAL             8. 0025720: RSAG998 - Numeración de pólizas por rangos
     9.0        04/02/2014   FAL             9. 0029965: RSA702 - GAPS renovación
     10.0       08/03/2019   CES             10. IAXIS-2420 Se agrega el procedimiento P_CAMBIO_REGIMEN para envio de corrreo en cambio de regimen simplificado a común.
		 11.0       28/03/2019   JLTS            11. IAXIS-3363. Se agregaran parametros a las funciones f_cuerpo y f_mail
 ******************************************************************************/
   FUNCTION f_origen(pscorreo IN NUMBER, p_from OUT VARCHAR2, paviso IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_destinatario(
      pscorreo IN NUMBER,
      psseguro IN NUMBER,
      p_to OUT VARCHAR2,
      p_to2 OUT VARCHAR2,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_cuerpo(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      ptexto OUT VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnsinies IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL,
      ptcuerpo IN VARCHAR2 DEFAULT NULL,   -- 2. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
      pcramo IN NUMBER DEFAULT NULL,   -- BUG 25720 - FAL - 02/09/2013
      psrdian IN NUMBER DEFAULT NULL ) -- IAXIS-3363 - JLTS - 28/03/2019
      RETURN NUMBER;

   FUNCTION f_asunto(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      psubject OUT VARCHAR2,
      psseguro IN NUMBER,
      pcmotmov IN NUMBER,
      ptasunto IN VARCHAR2
            DEFAULT NULL   -- 2. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
                        )
      RETURN NUMBER;

   FUNCTION f_mail(
      pscorreo IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcidioma IN NUMBER,
      pcaccion IN VARCHAR2,
      pmail OUT VARCHAR2,
      pasunto OUT VARCHAR2,
      pfrom OUT VARCHAR2,
      pto OUT VARCHAR2,
      pto2 OUT VARCHAR2,
      perror OUT VARCHAR2,
      pnsinies IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL,
      paviso IN NUMBER DEFAULT NULL,
      ptasunto IN VARCHAR2 DEFAULT NULL,   -- 2. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
      ptcuerpo IN VARCHAR2 DEFAULT NULL,   -- 2. 0022753: MDP_A001-Cierre de remesa (añadido parámetro)
      pcramo IN NUMBER DEFAULT NULL,   -- BUG 25720 - FAL - 02/09/2013
      pdestino IN VARCHAR2 DEFAULT NULL,
			psrdian IN NUMBER DEFAULT NULL) -- IAXIS-3363 - JLTS - 28/03/2019
      RETURN NUMBER;

   FUNCTION f_poliza(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_solicitud(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_clausula(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_sobreprima(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER DEFAULT 2)
      RETURN VARCHAR2;

   FUNCTION f_assegurado(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_pruebas(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_contactos(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_beneficiarios(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_benefmov(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_oficina(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_garantias(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_rechazo(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)   -- BUG 29965 - FAL - 07/02/2014
      RETURN VARCHAR2;

   FUNCTION f_certificado(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_gestion(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_movimiento(pcmotmov IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tipomov(pcmotmov IN NUMBER, pcidioma IN NUMBER, pasunto IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_ramo(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_nif(psseguro IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_riesgo(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_benefirrev(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tramitadora
      RETURN VARCHAR2;

   FUNCTION f_producto(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_falta(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_solicitud_reempl(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_fefecto(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_fcancel(psseguro IN NUMBER)
      RETURN VARCHAR2;

   -- BUG 0018967 - 07/09/2011 - JMF
   PROCEDURE p_log_correo(
      pevento IN DATE,
      pmrecep IN VARCHAR2,
      pusuari IN VARCHAR2,
      pasunto IN VARCHAR2,
      pterror IN VARCHAR2,
      poficin IN VARCHAR2,
      ptermin IN VARCHAR2);

   -- 5. 0022753: MDP_A001-Cierre de remesa - Inicio
   /*******************************************************************************
   FUNCION f_reemplaza_valores
   Función que reemplaza los valores de los parámetros que se puedan incluir en
   el texto del asunto o del cuerpo del mail.El número de parámetros es ilimitado

   Ejemplo:  '
   psubject := 'A fecha #1# la remesa #2#';
   ptcuerpo := '12/12/2012|55';
   retorna     'A fecha 12/12/2012 la remesa 55'

   Parámetros:
    Entrada :
       psubject
       ptcuerpo

   Retorna: texto modificado.
   ********************************************************************************/
   FUNCTION f_reemplaza_valores(psubject VARCHAR2, ptcuerpo VARCHAR2)
      RETURN VARCHAR2;

-- 5. 0022753: MDP_A001-Cierre de remesa - Fin

   -- BUG: 25910  AMJ   05/02/2013   0025910: LCOL: Enviament de correu en el proc?s de liquidaci?   Ini
   FUNCTION f_envia_correo(
      pvidioma IN NUMBER,
      psproliq IN NUMBER,
      pctipo IN NUMBER DEFAULT 13,
      ptexto IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_envia_correo_agentes(
      pcagente IN NUMBER,
      pvidioma IN NUMBER,
      pscorreo IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      pdirectorio IN VARCHAR2,
      pfichero IN VARCHAR2,
      pctipo IN NUMBER DEFAULT 17,
      ptexto IN VARCHAR2 DEFAULT NULL,
      pdirectorio2 IN VARCHAR2 DEFAULT 'GEDOXTEMPORAL',
      pfichero2 IN VARCHAR2 DEFAULT NULL,
      ptoccc IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
/*
   FUNCTION f_envia_correo_listado_agentes(
      pscorreo IN NUMBER,
      pfenvio IN DATE,
      pfinicio IN DATE,
      pfinal IN DATE,
      pcorreoresumen IN VARCHAR2,
      pdirectorio IN VARCHAR DEFAULT 'GEDOXTEMPORAL',
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
*/
  FUNCTION f_tomador(
        psseguro  IN NUMBER)
      RETURN VARCHAR2;

  FUNCTION f_estadopol(
        psseguro  IN NUMBER)
      RETURN VARCHAR2;

  FUNCTION f_usuariopol(
        psseguro  IN NUMBER)
      RETURN VARCHAR2;

  FUNCTION f_sistema
      RETURN VARCHAR2;

  FUNCTION f_origen_tarea(pnsinies  IN NUMBER,
                          pntramit  IN NUMBER,
                          pidapunte IN NUMBER) RETURN VARCHAR2;

  FUNCTION f_descripcion_tarea(pidapunte IN NUMBER) RETURN VARCHAR2;

PROCEDURE P_CAMBIO_REGIMEN (P_CAGENTE IN NUMBER);

END pac_correo;
/
