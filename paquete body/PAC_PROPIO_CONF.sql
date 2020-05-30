/* Formatted on 2020/01/31 15:40 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY pac_propio_conf
IS
   /******************************************************************************
     NOMBRE:     PAC_PROPIO_CONF
     PROPÓSITO:  Package que contiene las funciones propias de cada empresa.a

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        17/06/2011   DRA              1.0 0018790: LCOL001 - Alta empresa Liberty Colombia en DESA y TEST
     2.0        30/09/2011   JMF              2.0 0018967: LCOL_T005 - Listas restringidas validaciones y controles
     3.0        25/10/2011   JMF              3.0 0019791: LCOL_A001-Modificaciones de fase 0 en la consulta de recibos
     4.0        17/11/2011   ASN              4.0 0019416: LCOL_S001-Siniestros y exoneración de pago de primas
     4.0        17/10/2011   JMC              4.0 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
     5.0        05/12/2011   JMP              5.0 0018243: LCOL000 - Multimoneda
     6.0        14/12/2011   RSC              6.0 0019715: LCOL: Migración de productos de Vida Individual
     7.0        17/12/2011   JRH              7.0 0019927: LCOL: Carátula única
     8.0        17/12/2011   JRH              8.0 0020905: LCOL897 - INCIDENCIA IMPRESIONS
     9.0        05/01/2012   MDS              9.0 0020105: LCOL898 - Interfaces - Regulatorio - Reporte Encuesta Fasecolda
    10.0        17/01/2012   MDS             10.0 0020102: LCOL898 - Interface - Financiero - Carga de Comisiones Liquidadas
    11.0        16/01/2012   JMP             11.0 0018243: LCOL705 - Multimoneda
    12.0        30/01/2012   APD             12.0 0019303: LCOL_T003-Procés Saldar/Prorrogar
    13.0        09/02/2012   MDS             13.0 0021120: LCOL897-LCOL_A001-Resumen y detalle de las domiciliaciones y de las prenotificaciones
    14.0        21/03/2012   RSC             14.0 0021780: LCOL_T001 - Ajuste parametrización plantillas del producto Seguro Saldado y Seguro Prorrogado
    15.0        22/03/2012   RSC             15.0 0021808: LCOL - UAT - Revisión de Listados Producción
    16.0        29/03/2012   RSC             16.0 0021863: LCOL - Incidencias Reservas
    17.0        26/04/2012   AVT             17.0 0022020: LCOL999-Diferencias en las primas de reaseguro
    18.0        09/05/2012   MDS             18.0 0021974: LCOL898-UAT- error en la interficie de comisiones liquidadas
    19.0        18/05/2012   JMF             19.0 0022302: LCOL_A001: Llistat de liquidacions
    20.0        29/06/2012   MDS             20.0 0022687: LCOL - Una Anulación al Efecto no debe crear movimientos de devolucion de valor de rescate ni devolucion de valores de cesion
    21.0        30/07/2012   JLTS            21. 0023175: LCOL897-LCOL - Listado prestamos saldo pendientes
    22.0        05/09/2012   MCA             22. 0023545: LCOL: Impuestos de la comisión de ahorro en la interface
    23.0        06/09/2012   MDS             23. 0023254: LCOL - qtrackers 4806 / 4808. Màxim dels prestecs.
    24.0        13/09/2012   MDS             24. 0023340: LCOL_T001-No se puede Generar listado de impagados de prestamos (q-tracker:4364 )
    25.0        17/09/2012   MCA             25. 0023708: LCOL: Ajuste para la interface de comisiones liquidada y producción de comisiones
    26.0        02/10/2012   JGR             26. 0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752
    27.0        08/10/2012   JGR             27. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
    28.0        19/10/2012   DRA             28. 0023911: LCOL: Añadir Retorno para los productos Colectivos
    29.0        14/01/2013   ECP             29. 0023644: LCOL_A002-Qtracker: 0004565: Cesion de Siniestro no descuenta reserva matematica
    30.0        13/02/2013   MMS             30. 0024497: POS101 - Configuraci?n Rentas Vitalicias. Numeración de la póliza en POS
    31.0        14/02/2013   MMS             31. 0024497: POS101 - Configuraci?n Rentas Vitalicias. Quitamos la pregunta 4044 de fppenali_finv
    32.0        25/03/2013   ETM             32. 0026085: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 178 - Creaci?n prod: Saldado, Prorrogado, Convertibilidad (Fase 2)
    33.0        28/05/2013   MDS             33. 0026085: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 178 - Creacion prod: Saldado, Prorrogado, Convertibilidad (Fase 2)
    34.0        16/07/2013   MDS             34. 0026420: POSRA200-Parametrizaci?n Final de Vida Individual
    35.0        23/08/2013   MDS             35. 0027304: POSS518 (POSSF200)- Resolucion de Incidencias FASE 1-2: Tecnico - Rentas Vitalicias
    36.0        25/02/2014   JGR             36. 0029175: POSND100-POSADM - D?as de Gracia (actualizar la acción 7) - 0167397
    37.0        04/03/2014   NSS             37. 0029224/0166661: (POSAN500)-Analisis-Siniestros-Nuevos Desarrollos
    38.0        17/03/2014   JTT             38. 0024708: Generacion autmatica de pagos de renta mensual F_pago_renta_aut
    39.0        19/03/2014   JGR             39. 0030238#c169950: POSADM/TEC - CRUCE AUTOMÀTICO DE SUPLEMENTOS EN PÒLIZA ANULADA
    40.0        24/03/2014   JGR             40. 0030307#c170681 - Modificar el PAC_PROPIO_CONF, redondear el cálculo de prov.mat
    41.0        10/04/2014   JGR             41. 0025611#c171446 - En pruebas internas de cargas de ARL vemos que no se crean los recaudos
    42.0        23/04/2014   JTT             42. 0029943: Modificar el valor de rescate sumando el valor de PB - Participacion de Beneficions
    43.0        24/04/2014   JGR             43. 0029175: POSND100-POSADM - D?as de Gracia - Añadir EXCEPTION
    44.0        30/04/2014   FAL             44. 0027642: RSA102 - Producto Tradicional
    45.0        25/06/2014   AGG             45. 0029943: POSRA200 - Gaps 27,28 Anexos de PU en VIb
    46.0        27/08/2014   AGG             46. 0031531: POSPER.V.I. Listras restrictivas. Aplica para todas las polizas de Vida Individual
    47.0        20/01/2014   JTT             47. 0033544/192270: Compensación recibos pendientes al saldar/prorrogar la poliza
    48.0        12/02/2014   JTT             48. 0033544/192270: Se corrige el acceos a la tabla REEMPLAZOS en F_post_anulacion
    49.0        09/02/2018   ACL             49. 0001877: Se modifica la función f_desc_movres e inserte el tipo de transacción al realizar un pago en el histórico de reservas.
    50.0        14/02/2018   ACL             50. 0001876: Se agrega filtros en la select que trae el campo cconpag de la tabla sin_tramita_pago en la función f_desc_movres cuando es pago.
    51.0        20/02/2018   ACL             51. 0001881: Se modifica la función f_desc_movres para el cmovres 24 y muestre el tipo de transacción en el histórico de reservas.
    52.0        28/02/2018   ACL             52. 0001926: Se modifica la función f_desc_movres para el cmovres 22 y muestre el tipo de transacción en el histórico de reservas.
    53.0        06/03/2018   ACL             53. 0001942: Se modifica la función f_desc_movres para el cmovres 2 y muestre los tipos de transacciones en el histórico de reservas correspondiente al último acuerdo.
    54.0        28/05/2019   ECP             54. IAXIS/3592. Proceso de terminación por no pago
    55.0        02/09/2019   ECP             55. IAXIS-5149. Verificación por qué no se esta ejecutando el proceso de cancelación por no pago.
    56.0        04/09/2019   DFR             56. IAXIS-4832(12): Refinamiento revision final
    57.0        20/09/2019   ECP             57. IAXIS-5149. Verificación por qué no se esta ejecutando el proceso de cancelación por no pago.
   ******************************************************************************/

   /*************************************************************************
     FUNCTION f_esta_reducida
       Indica si una póliza esta o no reducida. Estará reducida si todos los detalles
       de garantía tiene prima = 0.

     param in psseguro  : Identificador de seguro.
     return             : NUMBER (1 --> Reducida / 0 --> No reducida)
   *************************************************************************/
   /* Bug 10828 - 10/09/2009 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)*/

   /***********************************************************************
          FUNCTION f_nsolici,
          Devuelve un nuevo solicitud.
          param in p_cramo: código de ramo
          return:         nuevo número de secuencia
   ***********************************************************************/
   /* BUG 0019332 - 30/08/2011 - JMF*/
   FUNCTION f_nsolici (p_cramo IN NUMBER)
      RETURN NUMBER
   IS
      v_nsolicit   estseguros.nsolici%TYPE;
   BEGIN
      SELECT ssolicit.NEXTVAL
        INTO v_nsolicit
        FROM DUAL;

      RETURN v_nsolicit;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_conf.f_nsolici',
                      1,
                      'parametros: p_cramo =' || p_cramo,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN NULL;
   END;

--Ini CONF-219 AP
  /*************************************************************************
  FUNCTION F_EXTRAE_NPOLCONTRA
  Extrae el nº de poliza del codigo de contrato (preguntas 4097)
  param in pncontinter  : Código de contrato
  param in pcempres     : Codigo de la empresa
  return             : Nº poliza
  *************************************************************************/
   FUNCTION f_extrae_npolcontra (pncontrato IN VARCHAR2, pcempres NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_poliza
      IS
         SELECT s.npoliza
           FROM seguros s
          WHERE EXISTS (
                   SELECT *
                     FROM pregunpolseg g
                    WHERE g.sseguro = s.sseguro
                      AND g.cpregun = 4097
                      AND TRIM (g.trespue) = TRIM (pncontrato)
                      AND g.nmovimi = (SELECT MAX (g1.nmovimi)
                                         FROM pregunpolseg g1
                                        WHERE g1.sseguro = g.sseguro))
            AND s.csituac NOT IN (2, 3)
            AND s.cempres = pcempres;

      c_poliza_r   c_poliza%ROWTYPE;
   BEGIN
      OPEN c_poliza;

      FETCH c_poliza
       INTO c_poliza_r;

      IF c_poliza%NOTFOUND
      THEN
         RETURN NULL;
      ELSE
         IF c_poliza%ISOPEN
         THEN
            CLOSE c_poliza;
         END IF;

         RETURN c_poliza_r.npoliza;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_conf.f_extrae_npolcontra',
                      1,
                         'parametros: pncontrato ='
                      || pncontrato
                      || ' - pcempres='
                      || pcempres,
                         SQLCODE
                      || ' '
                      || SQLERRM
                      || ' * '
                      || DBMS_UTILITY.format_error_backtrace
                     );
         RETURN NULL;
   END f_extrae_npolcontra;

--Fi CONF-219 AP
   FUNCTION f_desc_movres (
      pnsinies        IN   sin_tramita_reserva.nsinies%TYPE,
      pntramit        IN   sin_tramita_reserva.ntramit%TYPE,
      pctipres        IN   sin_tramita_reserva.ctipres%TYPE,
      pnmovres        IN   sin_tramita_reserva.nmovres%TYPE,
      pcmovres        IN   sin_tramita_reserva.cmovres%TYPE,
      pcsolidaridad   IN   sin_tramita_reserva.csolidaridad%TYPE DEFAULT NULL,
      pcidioma        IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      v_obj       VARCHAR2 (200)           := 'PAC_PROPIO_CONF.f_desc_movres';
      v_par       VARCHAR2 (200)
         :=    'pnsinies = '
            || pnsinies
            || ' pntramit: '
            || pntramit
            || ' pctipres: '
            || pctipres
            || ' pnmovres: '
            || pnmovres
            || ' pcmovres: '
            || pcmovres
            || ' pcidioma: '
            || pcidioma;
      v_pas       NUMBER (4)                      := 0;
      v_cconpag   sin_tramita_pago.cconpag%TYPE;
      v_tmovres   sin_desmovres.tmovres%TYPE;
      v_ctipcoa   seguros.ctipcoa%TYPE;
      v_return    VARCHAR2 (500);             -- CONF- 1877 - ACL - 09/02/2018
   BEGIN
      v_pas := 10;

      SELECT s.ctipcoa
        INTO v_ctipcoa
        FROM sin_siniestro sn, seguros s
       WHERE s.sseguro = sn.sseguro AND sn.nsinies = pnsinies;

      --
      IF pcmovres IN (4, 22)
      THEN                                      -- CONF-1881 - ACL- 20/02/2018
            --
         -- INI CONF-1877 - ACL- 09/02/2018
           /* SELECT sp.cconpag
              INTO v_cconpag
              FROM sin_tramita_pago sp
             WHERE sp.nsinies = pnsinies
               AND sp.ntramit = pntramit;
            --
            RETURN ff_desvalorfijo(803, pcidioma, v_cconpag);*/
         SELECT sp.cconpag
           INTO v_cconpag
           FROM sin_tramita_pago sp
          WHERE sp.nsinies = pnsinies
            AND sp.ntramit = pntramit
            AND sp.sidepag =
                   (SELECT st.sidepag
                      FROM sin_tramita_reserva st
                     WHERE st.nsinies = pnsinies
                       AND st.ntramit = pntramit
                       AND st.nmovres = pnmovres
                       AND st.ctipres = pctipres
                       -- CONF-1876 - ACL- 14/02/2018
                       AND st.csolidaridad = pcsolidaridad);

         -- CONF-1876 - ACL- 14/02/2018

         --
         SELECT SUBSTR (ff_desvalorfijo (803, pcidioma, v_cconpag), 7)
           INTO v_return
           FROM DUAL;

         RETURN v_return;
      -- FIN CONF-1877 - ACL- 09/02/2018
         --
      ELSIF pcmovres IN (7, 8, 11, 12, 13, 14, 15, 19, 20, 21, 23, 24, 25)
      THEN
         --
         SELECT sd.tmovres
           INTO v_tmovres
           FROM sin_desmovres sd
          WHERE sd.cmovres = pcmovres AND sd.cidioma = pcidioma;

         --
         RETURN v_tmovres;
      ELSIF pcmovres IN (0, 1)
      THEN
         IF v_ctipcoa = 1 AND pcsolidaridad = 0
         THEN
            IF pctipres = 1
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 1);
            ELSIF pctipres = 3
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 2);
            ELSIF pctipres = 5
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 40);
            END IF;
         ELSE
            IF pctipres = 1
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 3);
            ELSIF pctipres = 3
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 4);
            ELSIF pctipres = 5
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 41);
            END IF;
         END IF;
      /* ELSIF pcmovres =2 THEN
          IF v_ctipcoa = 1 AND pcsolidaridad = 0 THEN
             -- RETURN ff_desvalorfijo(8001112, pcidioma, 22);
             RETURN ff_desvalorfijo(8001112, pcidioma, 2); -- CONF-1926 - ACL- 28/02/2018
          ELSIF pctipres = 1 THEN
             RETURN ff_desvalorfijo(8001112, pcidioma, 23);
          ELSE
             --RETURN ff_desvalorfijo(8001112, pcidioma, 24);
          RETURN ff_desvalorfijo(8001112, pcidioma, 4); -- CONF-1881 - ACL- 20/02/2018
          END IF; */

      -- INI CONF-1942 - ACL- 28/02/2018
      ELSIF pcmovres = 2
      THEN
         IF v_ctipcoa = 1 AND pcsolidaridad = 0
         THEN
            IF pctipres = 1
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 22);
            ELSIF pctipres = 3
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 34);
            ELSIF pctipres = 5
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 44);
            END IF;
         ELSE
            IF pctipres = 1
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 23);
            ELSIF pctipres = 3
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 33);
            ELSIF pctipres = 5
            THEN
               RETURN ff_desvalorfijo (8001112, pcidioma, 43);
            END IF;
         END IF;
      -- FIN CONF-1942 - ACL- 28/02/2018
      ELSIF pcmovres = 3
      THEN
         IF pctipres = 3
         THEN
            RETURN ff_desvalorfijo (8001112, pcidioma, 31);
         ELSIF pctipres = 1
         THEN
            RETURN ff_desvalorfijo (8001112, pcidioma, 32);
         ELSIF pctipres = 5
         THEN
            RETURN ff_desvalorfijo (8001112, pcidioma, 42);
         END IF;
      ELSE
         --
         RETURN ff_desvalorfijo (8001112, pcidioma, pcmovres);
      --
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_obj,
                      v_pas,
                      v_par,
                      SQLCODE || '-' || SQLERRM
                     );
         RETURN NULL;
   END f_desc_movres;

   --AAC_INI-CONF_OUTSOURCING-20160906
   FUNCTION p_personas_rel (psperson NUMBER, pctipper_rel NUMBER)
      RETURN VARCHAR2
   IS
      v_var   VARCHAR2 (2000) := '';
      v_aux   VARCHAR2 (2000) := '';
   BEGIN
      FOR c IN (SELECT *
                  FROM per_personas_rel
                 WHERE sperson = psperson AND ctipper_rel = pctipper_rel)
      LOOP
         DBMS_OUTPUT.put_line (c.sperson_rel);

         SELECT    pdp.tnombre
                || ' '
                || pdp.tnombre2
                || ' '
                || pdp.tapelli1
                || ' '
                || pdp.tapelli2
           INTO v_aux
           FROM per_detper pdp
          WHERE pdp.sperson = c.sperson;

         v_var := v_var || ';' || v_aux;
      END LOOP;

      RETURN v_var;
   END p_personas_rel;

   --AAC_FI-CONF_OUTSOURCING-20160906

   --OGQ_INI_CONF-513
   FUNCTION f_contador2 (
      p_tipo   IN   VARCHAR2,
      p_caux   IN   NUMBER,
      p_exp    IN   NUMBER DEFAULT 6
   )
      RETURN NUMBER
   IS
      v_retorno   VARCHAR2 (15);
      v_num       NUMBER;
      v_produc    NUMBER;
   BEGIN
      --Busqueda del producto
      BEGIN
         --
         SELECT sproduc
           INTO v_produc
           FROM seguros
          WHERE sseguro = p_exp;
      --
      EXCEPTION
         WHEN OTHERS
         THEN
            v_produc := p_caux;
      END;

      --Para siniestros
      IF p_tipo = '01'
      THEN
         --
         v_num := f_contador (p_tipo, v_produc);
         v_retorno := TO_CHAR (SYSDATE, 'YYYY') || v_num;
      --
      ELSE
         --
         v_retorno := f_contador (p_tipo, p_caux);
      --
      END IF;

      --
      RETURN TO_NUMBER (v_retorno);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         p_tab_error (f_sysdate,
                      f_user,
                      p_tipo,
                      p_caux,
                      p_exp,
                      SQLCODE || '-' || SQLERRM
                     );
         RETURN NULL;
   --
   END f_contador2;

   --OGQ_FI_CONF-513
   /*************************************************************************
      FUNCTION    FF_PCOMISI_PCOMISI
      PROPÓSITO:  Función que llama a la función f_pcomisi,
                  calculando algunos de los parámetros de entrada,
                  y devuelve el valor ppcomisi de f_pcomisi
    *************************************************************************/
   FUNCTION ff_pcomisi_pcomisi (
      psseguro   IN   NUMBER,
      pnrecibo   IN   NUMBER,
      pcgarant   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vcmodcom      NUMBER;
      vcagente      seguros.cagente%TYPE;
      vcramo        seguros.cramo%TYPE;
      vcmodali      seguros.cmodali%TYPE;
      vctipseg      seguros.ctipseg%TYPE;
      vccolect      seguros.ccolect%TYPE;
      vcactivi      seguros.cactivi%TYPE;
      vsproduc      seguros.sproduc%TYPE;
      vfefectoseg   seguros.fefecto%TYPE;
      vnanuali      seguros.nanuali%TYPE;
      vfemisiorec   recibos.femisio%TYPE;
      vfefectorec   recibos.fefecto%TYPE;
      vfefectovig   DATE;
      vpcomisi      NUMBER;
      vpretenc      NUMBER;
      verrfunc      EXCEPTION;
      verror        NUMBER;
      vpasexec      NUMBER (8)             := 1;
      vparam        VARCHAR2 (2000)
         :=    'psseguro :'
            || psseguro
            || ' - pnrecibo :'
            || pnrecibo
            || ' - pcgarant :'
            || pcgarant;
      -- Bug 0022302 - JMF - 18/05/2012: afegir ctiprec
      vctiprec      recibos.ctiprec%TYPE;
   BEGIN
      vpasexec := 2;

      -- obtener vcmodcom
      IF f_es_renovacion (psseguro) = 0
      THEN
         -- es cartera
         vcmodcom := 2;
      ELSE
         -- es nueva producción
         vcmodcom := 1;
      END IF;

      -- obtener información del seguro
      vpasexec := 3;

      SELECT cagente, cramo, cmodali, ctipseg, ccolect, cactivi,
             sproduc, fefecto, nanuali
        INTO vcagente, vcramo, vcmodali, vctipseg, vccolect, vcactivi,
             vsproduc, vfefectoseg, vnanuali
        FROM seguros
       WHERE sseguro = psseguro;

      -- obtener información del recibo
      vpasexec := 4;

      -- Bug 0022302 - JMF - 18/05/2012: afegir ctiprec
      SELECT femisio, fefecto, ctiprec
        INTO vfemisiorec, vfefectorec, vctiprec
        FROM recibos
       WHERE nrecibo = pnrecibo;

      -- obtener vfefectovig
      vpasexec := 5;

      IF NVL (pac_parametros.f_parproducto_t (vsproduc, 'FVIG_COMISION'),
              'FEFECTO_REC'
             ) = 'FEFECTO_REC'
      THEN
         vfefectovig := vfefectorec;                     -- efecto del recibo
      ELSIF pac_parametros.f_parproducto_t (vsproduc, 'FVIG_COMISION') =
                                                                 'FEFECTO_POL'
      THEN
         -- efecto de la póliza
         BEGIN
            SELECT TO_DATE (crespue, 'YYYYMMDD')
              INTO vfefectovig
              FROM pregunpolseg
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX (p.nmovimi)
                                FROM pregunpolseg p
                               WHERE p.sseguro = psseguro)
               AND cpregun = 4046;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vfefectovig := vfefectoseg;
         END;
      ELSIF pac_parametros.f_parproducto_t (vsproduc, 'FVIG_COMISION') =
                                                              'FEFECTO_RENOVA'
      THEN
         -- efecto a la renovación
         vfefectovig := TO_DATE (frenovacion (NULL, psseguro, 2), 'yyyymmdd');
      END IF;

      -- llamada a f_pcomisi
      vpasexec := 6;
      -- ini Bug 0022302 - JMF - 18/05/2012: afegir ctiprec
      -- En los recibos de ahorro se ha de ir a mirar el de rendimiento a la tramo (si existe)
      vpcomisi := NULL;
      verror := 0;

      IF vctiprec = 5
      THEN
         pac_propio_conf.proceso_liscomis_calcom (vsproduc, verror, vpcomisi);

         IF verror <> 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_propio_conf.ff_pcomisi_pcomisi',
                         vpasexec,
                         'error=' || verror,
                         vsproduc
                        );
            verror := 0;
         END IF;
      END IF;

      IF verror = 0 AND vpcomisi IS NULL
      THEN
         verror :=
            f_pcomisi (psseguro,
                       vcmodcom,
                       vfemisiorec,
                       vpcomisi,
                       vpretenc,
                       vcagente,
                       vcramo,
                       vcmodali,
                       vctipseg,
                       vccolect,
                       vcactivi,
                       pcgarant,
                       NULL,
                       'CAR',
                       vfefectovig,
                       vnanuali
                      );
      END IF;

      -- fin Bug 0022302 - JMF - 18/05/2012: afegir ctiprec
      IF verror <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_conf.ff_pcomisi_pcomisi',
                      vpasexec,
                      'llamada a f_pcomisi',
                      verror
                     );
         RAISE verrfunc;
      ELSE
         RETURN vpcomisi;
      END IF;
   EXCEPTION
      WHEN verrfunc
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'Error llamada a f_pcomisi',
                      vpasexec,
                      vparam || ': Error' || SQLCODE,
                      SQLERRM
                     );
         RETURN NULL;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_pos.ff_pcomisi_pcomisi',
                      vpasexec,
                      vparam || ': Error' || SQLCODE,
                      SQLERRM
                     );
         RETURN NULL;
   END ff_pcomisi_pcomisi;

   /*************************************************************************
   FUNCTION proceso_liscomis_calcom
   Calcula la comisión para un producto
   param in psproduc    : codigo producto
   param in out perror  : 0=bien, numero=codigo error
   param in out pcomisi : porcentaje comisión
   *************************************************************************/
   PROCEDURE proceso_liscomis_calcom (
      psproduc   IN       NUMBER,
      perror     OUT      NUMBER,
      pcomisi    OUT      NUMBER
   )
   IS
      vobj   VARCHAR2 (200) := 'PAC_PROPIO_CONF.proceso_liscomis_calcom';
      vpar   VARCHAR2 (200) := 'psproduc=' || psproduc;
      vpas   NUMBER         := 0;
   BEGIN
      perror := 0;
      pcomisi := NULL;
      vpas := 10;

      IF psproduc IS NULL
      THEN
         RAISE VALUE_ERROR;
      END IF;

      vpas := 20;

      SELECT valor
        INTO pcomisi
        FROM sgt_det_tramos
       WHERE tramo = 290 AND desde = psproduc;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vpas,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         pcomisi := NULL;
         perror := SQLCODE;
   END;

   FUNCTION f_tdomici (
      pcsiglas     IN   per_direcciones.csiglas%TYPE,
      ptnomvia     IN   per_direcciones.tnomvia%TYPE,
      pnnumvia     IN   per_direcciones.nnumvia%TYPE,
      ptcomple     IN   per_direcciones.tcomple%TYPE,
      -- Bug 18940/92686 - 27/09/2011 - AMC
      pcviavp      IN   per_direcciones.cviavp%TYPE DEFAULT NULL,
      pclitvp      IN   per_direcciones.clitvp%TYPE DEFAULT NULL,
      pcbisvp      IN   per_direcciones.cbisvp%TYPE DEFAULT NULL,
      pcorvp       IN   per_direcciones.corvp%TYPE DEFAULT NULL,
      pnviaadco    IN   per_direcciones.nviaadco%TYPE DEFAULT NULL,
      pclitco      IN   per_direcciones.clitco%TYPE DEFAULT NULL,
      pcorco       IN   per_direcciones.corco%TYPE DEFAULT NULL,
      pnplacaco    IN   per_direcciones.nplacaco%TYPE DEFAULT NULL,
      pcor2co      IN   per_direcciones.cor2co%TYPE DEFAULT NULL,
      pcdet1ia     IN   per_direcciones.cdet1ia%TYPE DEFAULT NULL,
      ptnum1ia     IN   per_direcciones.tnum1ia%TYPE DEFAULT NULL,
      pcdet2ia     IN   per_direcciones.cdet2ia%TYPE DEFAULT NULL,
      ptnum2ia     IN   per_direcciones.tnum2ia%TYPE DEFAULT NULL,
      pcdet3ia     IN   per_direcciones.cdet3ia%TYPE DEFAULT NULL,
      ptnum3ia     IN   per_direcciones.tnum3ia%TYPE DEFAULT NULL,
      -- Fi Bug 18940/92686 - 27/09/2011 - AMC
      plocalidad   IN   per_direcciones.localidad%TYPE
            DEFAULT NULL                -- Bug 24780/130907 - 05/12/2012 - AMC
   )
      RETURN VARCHAR2
   IS
      vtsiglas   VARCHAR2 (6)                   := NULL;
      -- IAXIS-4832(12) 04/09/2019
      vnnomvia   NUMBER;
      vnnumvia   NUMBER;
      vncomple   NUMBER;
      vtdomici   per_direcciones.tdomici%TYPE;  --JMC- 01/10/2010 - Bug 15495
      tviavp     VARCHAR2 (250);
      tdet1ia    VARCHAR2 (50);
      tdet2ia    VARCHAR2 (50);
      tdet3ia    VARCHAR2 (50);
      tclitvp    VARCHAR2 (50);
      tbisvp     VARCHAR2 (50);
      tcorvp     VARCHAR2 (50);
      tlitco     VARCHAR2 (50);
      tcorco     VARCHAR2 (50);
      tor2co     VARCHAR2 (50);
   BEGIN
      IF pcsiglas IS NOT NULL
      THEN
         BEGIN
            SELECT tsiglas
              INTO vtsiglas
              FROM tipos_via
             WHERE csiglas = pcsiglas;

            vtdomici := vtsiglas || ' ';
         EXCEPTION
            WHEN OTHERS
            THEN
               vtsiglas := NULL;
         END;
      END IF;

      -- Bug 21094/105198 - 27/01/2012 - AMC
      IF pcviavp IS NOT NULL
      THEN
         BEGIN
            SELECT tsiglas
              INTO vtsiglas
              FROM tipos_via
             WHERE csiglas = pcviavp;

            vtdomici := vtsiglas || ' ';
         EXCEPTION
            WHEN OTHERS
            THEN
               vtsiglas := NULL;
         END;
      END IF;

      -- Fi Bug 21094/105198 - 27/01/2012 - AMC

      -- Bug 18940/92686 - 27/09/2011 - AMC
--      IF ptnomvia IS NOT NULL THEN
      vnnomvia := NVL (LENGTH (ptnomvia), 0);
      vnnumvia := NVL (LENGTH (pnnumvia), 0);
      vncomple := NVL (LENGTH (ptcomple), 0);

      -- BUG 18507 - 11/05/2011- ETM--se modifica la concatenacion de la direccion
      IF (vnnomvia + vnnumvia + vncomple + 8) < 100
      THEN
         SELECT    vtdomici
                || ptnomvia
                || DECODE (pnnumvia,
                           NULL, ' '
                            || f_axis_literales (9001323, f_usu_idioma),
                           ' '
                          )
                || pnnumvia
                || DECODE (ptcomple, NULL, NULL, ' ')
                || ptcomple
           INTO vtdomici
           FROM DUAL;
      ELSE
         SELECT    vtdomici
                || SUBSTR (ptnomvia, 0, 100 - (vnnumvia + vncomple + 8))
                || DECODE (pnnumvia,
                           NULL, ' '
                            || f_axis_literales (9001323, f_usu_idioma),
                           ' '
                          )
                || pnnumvia
                || DECODE (ptcomple, NULL, NULL, ' ')
                || ptcomple
           INTO vtdomici
           FROM DUAL;
      END IF;

      -- Bug 18940/92686 - 27/09/2011 - AMC
      IF pclitvp IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tclitvp
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800043
               AND catribu = pclitvp;

            IF vtdomici IS NULL
            THEN
               vtdomici := tclitvp;
            ELSE
               vtdomici := vtdomici || ' ' || tclitvp;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF pcbisvp IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tbisvp
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800044
               AND catribu = pcbisvp;

            IF vtdomici IS NULL
            THEN
               vtdomici := tbisvp;
            ELSE
               vtdomici := vtdomici || ' ' || tbisvp;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF pcorvp IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tcorvp
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800045
               AND catribu = pcorvp;

            IF vtdomici IS NULL
            THEN
               vtdomici := tcorvp;
            ELSE
               vtdomici := vtdomici || ' ' || tcorvp;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF pnviaadco IS NOT NULL
      THEN
         vtdomici := vtdomici || ' ' || pnviaadco;
      END IF;

      IF pclitco IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tlitco
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800043
               AND catribu = pclitco;

            IF vtdomici IS NULL
            THEN
               vtdomici := tlitco;
            ELSE
               vtdomici := vtdomici || ' ' || tlitco;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF pcorco IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tcorco
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800045
               AND catribu = pcorco;

            IF vtdomici IS NULL
            THEN
               vtdomici := tcorco;
            ELSE
               vtdomici := vtdomici || ' ' || tcorco;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      --  vtdomici := vtdomici || ' ' || pnviaadco || ' ' || tlitco || ' ' || tcorco;
      IF pnplacaco IS NOT NULL
      THEN
         vtdomici := vtdomici || ' ' || pnplacaco;
      END IF;

      IF pcor2co IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tor2co
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800045
               AND catribu = pcor2co;

            IF vtdomici IS NULL
            THEN
               vtdomici := tor2co;
            ELSE
               vtdomici := vtdomici || ' ' || tor2co;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF pcdet1ia IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tdet1ia
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800047
               AND catribu = pcdet1ia;

            IF vtdomici IS NULL
            THEN
               vtdomici := tdet1ia;
            ELSE
               vtdomici := vtdomici || ' ' || tdet1ia;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF ptnum1ia IS NOT NULL
      THEN
         IF vtdomici IS NULL
         THEN
            vtdomici := ptnum1ia;
         ELSE
            vtdomici := vtdomici || ' ' || ptnum1ia;
         END IF;
      END IF;

      IF pcdet2ia IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tdet2ia
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800047
               AND catribu = pcdet2ia;

            IF vtdomici IS NULL
            THEN
               vtdomici := tdet2ia;
            ELSE
               vtdomici := vtdomici || ' ' || tdet2ia;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF ptnum2ia IS NOT NULL
      THEN
         IF vtdomici IS NULL
         THEN
            vtdomici := ptnum2ia;
         ELSE
            vtdomici := vtdomici || ' ' || ptnum2ia;
         END IF;
      END IF;

      IF pcdet3ia IS NOT NULL
      THEN
         BEGIN
            SELECT tatribu
              INTO tdet3ia
              FROM detvalores
             WHERE cidioma = f_usu_idioma
               AND cvalor = 800047
               AND catribu = pcdet3ia;

            IF vtdomici IS NULL
            THEN
               vtdomici := tdet3ia;
            ELSE
               vtdomici := vtdomici || ' ' || tdet3ia;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF ptnum3ia IS NOT NULL
      THEN
         IF vtdomici IS NULL
         THEN
            vtdomici := ptnum3ia;
         ELSE
            vtdomici := vtdomici || ' ' || ptnum3ia;
         END IF;
      END IF;

      -- Fi Bug 18940/92686 - 27/09/2011 - AMC

      -- Bug 24780/130907 - 05/12/2012 - AMC
      IF plocalidad IS NOT NULL
      THEN
         IF vtdomici IS NULL
         THEN
            vtdomici := plocalidad;
         ELSE
            vtdomici := vtdomici || ', ' || plocalidad;
         END IF;
      END IF;

      -- Fi Bug 24780/130907 - 05/12/2012 - AMC
      RETURN vtdomici;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_PROPIO_LCOL.f_tdomici',
                      1,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN NULL;
   END f_tdomici;

     /*************************************************************************
      FUNCTION f_devolu_accion_7
      calcula valor de prorrata para recibos de polizas anuladas por no pago
      param in psproduc    : codigo producto
      param out perror  : 0=bien, numero=codigo error
      param out pcomisi : porcentaje comisión
   *************************************************************************/
   FUNCTION f_devolu_accion_7 (
      pcactimp   IN       NUMBER,
      pnrecibo   IN       NUMBER,
      pffejecu   IN       DATE,
      psseguro   IN       NUMBER,
      pcmotivo   IN       NUMBER,
      pffecalt   IN       DATE,
      piprovis   IN OUT   NUMBER,
      pcidioma   IN       NUMBER,
      psproces   IN       NUMBER
   )
      RETURN NUMBER
   IS
      v_csituac          NUMBER;
      vipendiente        NUMBER                     := 1;
      vcobrarec          NUMBER                     := 0;
      vcreteni           NUMBER;
      vfanulac           DATE;
      vproceslin         procesoslin.tprolin%TYPE;
      vnriesgo           NUMBER;
      vitotalr           NUMBER;
      vsproduc           NUMBER;
      vcactivi           NUMBER;
      vsmovagr           NUMBER                     := 0;
      vcdelega           NUMBER;
      vnrecibo           recibos.nrecibo%TYPE;
      vccobban           recibos.ccobban%TYPE;
      vcagente           recibos.cagente%TYPE;
      vfemisio           recibos.femisio%TYPE;
      vfefecto           recibos.fefecto%TYPE;
      vfvencim           recibos.fvencim%TYPE;
      vnmovimi           NUMBER;
      vtraza             NUMBER;
      vcmoneda           NUMBER;                           -- 60. 0027472 (+)
      vctipban           NUMBER;
      vcbancar           recibos.cbancar%TYPE;                      --NUMBER;
      vfanula            DATE;
      vnanuali           seguros.nanuali%TYPE;
      accion_error       EXCEPTION;
      vfrenova           DATE;                -- Bug 22084 - APD - 18/06/2012
      vfanula_poliza     DATE;                -- Bug 22084 - APD - 18/06/2012
      vfgracia_poliza    DATE;                -- Bug 22084 - APD - 18/06/2012
      vcforpag           seguros.cforpag%TYPE;
      vnnumdias_gracia   NUMBER;              -- Bug 22084 - APD - 18/06/2012
      vnmovimi_renova    movseguro.nmovimi%TYPE;
      vimpfactor         NUMBER;              -- Bug 22084 - APD - 18/06/2012
      vimprec            NUMBER;              -- Bug 22084 - APD - 18/06/2012
      v_tipocert         VARCHAR2 (20);       -- Bug 22084 - APD - 18/06/2012
      vnrecibo_aux       recibos.nrecibo%TYPE;
      -- Bug 22084 - APD - 18/06/2012
      -- 23.  0022738- 0120453 - Ult.Ver. - (+)
      num_err            NUMBER                     := 0;
      vcempres           seguros.cempres%TYPE;
      -- vcidioma       NUMBER := NVL(pcidioma, pac_md_common.f_get_cxtidioma);
      vproceso           VARCHAR2 (500)
                                       := 'pac_propio_conf.f_devolu_accion_7';
      -- 27. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
      v_rec_parc         NUMBER;
      vfcobros           DATE;
      -- BUG 24282 .JRV - 07/11/2012
      vitotalr_ini       NUMBER;
-- 38. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Nota: 0135027
      vrevocable         NUMBER;
-- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596
      --BUG 27472/149517 - INICIO - DCT - 22/07/2013  - 0027472: LCOL_A001-Terminaciones por no pago - Ajustar data d'estalvi
      w_cmoncon          parempresas.nvalpar%TYPE;
      vcramo             NUMBER;
      v_fecha            DATE;                                 -- 64. 0010069
      v_smlv_min         NUMBER;                               -- 64. 0010069
      v_isalmin          NUMBER;                               -- 64. 0010069
      vnmovimi_anul      movseguro.nmovimi%TYPE;               -- 76. 0029431
      vcubretotal        NUMBER                     := 0;

      --SHA 31/08/2015 - 36500/212942 : Error Cruces autom?ticos

      ---   Fin del bug 35648

      --BUG 27472/149517 - FIN - DCT - 22/07/2013  - 0027472: LCOL_A001-Terminaciones por no pago - Ajustar data d'estalvi
      -- 27. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
      -- 30. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0127366 - Inicio
      PROCEDURE p_pre_proceslin (
         psproces                  NUMBER,
         pproceslin       IN OUT   VARCHAR2,
         pproceslin_new   IN       VARCHAR2,
         psseguro                  NUMBER,
         pnrecibo                  NUMBER,
         pctiplin                  NUMBER
      )
      IS
         vtxt     VARCHAR2 (2000);
         vtraza   NUMBER;                            -- 58. 0027644 - QT-8596
      BEGIN
         vtraza := 10;
         vtxt := 'Recibo[' || pnrecibo || '] ' || pproceslin;
         vtraza := 20;
         vcubretotal := 0;

         --SHA 31/08/2015 - 36500/212942 : Error Cruces autom?ticos
         IF LENGTH (vtxt || pproceslin_new) > 120
         -- 81. 0030545: 10429 - Final
         THEN
            -- 58. 0027644 - QT-8596 - Inicio
            -- p_proceslin(psproces, vtxt, psseguro, 2);
            -- pproceslin := pproceslin_new;
            vtraza := 30;
            /*  p_proceslin(psproces, SUBSTR(vtxt, 1, 120), psseguro, 2);*/
            vtraza := 40;
            pproceslin := SUBSTR (pproceslin_new, 1, 120);
         -- 58. 0027644 - QT-8596 - Final
         ELSIF pctiplin = 1
         THEN
            --> Forzar que grabe l?nea (ideal para errores que despu?s hacen RAISE)
            vtraza := 42;
            p_control_error ('DAMIAN',
                             'LIN',
                                psproces
                             || ' '
                             || SUBSTR (vtxt || pproceslin_new, 1, 120)
                             || ' '
                             || psseguro
                            );

            IF LENGTH (vtxt || pproceslin_new) > 120
            THEN
               pproceslin := NULL;
               vtraza := 46;
            END IF;
         -- 81. 0030545: 10429 - Inicial - Tambi?n se modificaron el valor del par?metro en las llamadas acompa?adas de RAISE
         ELSE
            vtraza := 50;
            pproceslin := pproceslin || pproceslin_new;
         END IF;

         -- 58. 0027644 - QT-8596 - Inicio
         vtraza := 60;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_propio_conf.p_pre_proceslin',
                         vtraza,
                         NULL,
                         SQLERRM
                        );
      -- 58. 0027644 - QT-8596 - Final
      END;                               /*fin procedimiento p_pre_proceslin*/
   -- 30. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0127366 - Fin
   BEGIN
      vtraza := 10;
      piprovis := 0;
      vproceslin := NULL;

      BEGIN
         SELECT csituac, sproduc, cactivi, fanulac
                                                  -- 11. JGR 0021115: LCOL_A001-Rebuts no pagats i anticips
         ,      creteni, nanuali,
                -- 19. 10/05/2012 JGR 0022241 Anular p?l. prest.<d 1 ?.
                cforpag,                       -- Bug 22084 - APD - 18/06/2012
                        cempres, cramo
           INTO v_csituac, vsproduc, vcactivi, vfanulac
                                                       -- 11. JGR 0021115: LCOL_A001-Rebuts no pagats i anticips
         ,      vcreteni, vnanuali,
                -- 19. 10/05/2012 JGR 0022241 Anular p?l. prest.<d 1 ?.
                vcforpag,                      -- Bug 22084 - APD - 18/06/2012
                         vcempres, vcramo
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 101903;    -- seguro no encontrado en la tabla SEGUROS
      END;

      BEGIN
         SELECT v.itotalr, NVL (r.nriesgo, 1), r.ccobban, r.cdelega,
                r.cagente, r.femisio, r.fefecto, r.fvencim, r.ctipban,
                r.cbancar, r.nmovimi
           INTO vitotalr, vnriesgo, vccobban, vcdelega,
                vcagente, vfemisio, vfefecto, vfvencim, vctipban,
                vcbancar, vnmovimi
           FROM vdetrecibos_monpol v, recibos r
          WHERE r.nrecibo = pnrecibo AND v.nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 9001250;                       -- Recibo no encontrado
      END;

      vtraza := 15;
      w_cmoncon := pac_parametros.f_parempresa_n (vcempres, 'MONEDACONTAB');
      -- 60. 0027472
      vcmoneda := pac_monedas.f_moneda_producto (vsproduc);     -- 60. 0027472
      vtraza := 20;
      v_rec_parc :=
         pac_adm_cobparcial.f_get_importe_cobro_parcial (pnrecibo, NULL, NULL);
      vitotalr_ini := vitotalr;                    -- 38. 22346 28/01/2013 (+)

      IF v_rec_parc > 0
      THEN
         -- Si hay cobros parciales, calcula sobre importe pendiente (total recibo - importes parciales)
         vitotalr := vitotalr - v_rec_parc;
         vcobrarec := 1;
      END IF;

      IF vipendiente > 0
      THEN
         vtraza := 920;

         -- La fecha de anulaci?n de la p?liza no puede ser
         -- anterior a la coberturas de los recibos cobrados
         -- Bug 22084 - APD - 26/06/2012 - se modifica la select
         -- para poder obtener m?s informacion del recibo
         SELECT   r.fefecto, r.nrecibo, r.fvencim,
                  DECODE (esccero, 1, 'CERTIF0', NULL), nmovimi
             INTO vfanula, vnrecibo, vfvencim,
                  v_tipocert, vnmovimi
             FROM recibos r
            WHERE r.sseguro = psseguro
              AND f_cestrec (r.nrecibo, pffejecu) IN (0, 3)
              AND r.ctiprec <> 14
              AND r.ctiprec IN (0, 3)
              AND r.fefecto =
                     (SELECT MIN (re.fefecto)
                        FROM recibos re
                       WHERE re.sseguro = psseguro
                         AND f_cestrec (re.nrecibo, pffejecu) IN (0, 3)
                         AND re.ctiprec <> 14
                         AND re.ctiprec IN (0, 3))
              -- PROD 0020873: Solicitud de anulacion polizas fin periodo de gracia
              AND ROWNUM = 1
         ORDER BY r.nrecibo;

         -- 27. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
         -- En los cobros parciales la fecha de anulaci?n ha de ser la que retorna la
         -- funci?n que inserta los pagos (fecha hasta la que cubre el ?ltimo pago)
         IF v_rec_parc > 0 AND vfcobros IS NOT NULL
         THEN
            vfanula := vfcobros;
         END IF;

         vtraza := 930;

         -- Bug 22084 - APD - 18/06/2012
         -- Si existe alg?n recibo pendiente, se debe anular la poliza y los recibos que
         -- queden pendientes
         IF vfanula IS NOT NULL
         THEN
            -- Buscar la fecha de gracia desde la fecha ultima renovacion de la poliza
            num_err :=
                  f_ultrenova (psseguro, pffejecu, vfrenova, vnmovimi_renova);

            IF num_err != 0
            THEN
               RAISE accion_error;
            END IF;

            vtraza := 940;
            vnnumdias_gracia := pac_devolu.f_numdias_periodo_gracia (psseguro);
            vfgracia_poliza := vfrenova + vnnumdias_gracia;
               -- 81. 0030545: 10429 - Inicio
            -- Factor de cobro
            -- Salario M?nimo * Factor tiempo transcurrido seg?n modalidad de cobro
            -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Inicio
             /*  vimpfactor := NVL(pac_subtablas.f_vsubtabla(-1, 3000, 3, 1, 1), 0)
                           * NVL(pac_subtablas.f_vsubtabla(-1, 3001, 3, 1, vcforpag),
                                 0);
            */
            v_fecha :=
               pac_eco_tipocambio.f_fecha_max_cambio
                                           (pac_monedas.f_cmoneda_t (vcmoneda),
                                            'SMV',
                                            TRUNC (pffejecu)
                                           );
            v_smlv_min := NVL (f_parproductos_v (vsproduc, 'SMLMV_MIN'), 1);
            -- Salario M?nimo
            v_isalmin :=
               pac_eco_tipocambio.f_importe_cambio
                                           ('SMV',
                                            pac_monedas.f_cmoneda_t (vcmoneda),
                                            v_fecha,
                                            v_smlv_min
                                           );
            vimpfactor :=
                 v_isalmin
               * NVL (pac_subtablas.f_vsubtabla (-1, 3001, 3, 1, vcforpag), 0);
            -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Final
            -- Se busca cual seria el importe del recibo a generar que cubra el periodo de tiempo transcurrido
            -- Este importe es informativo debido a que se calcula directamente en la funcion "f_genera_recibo" con      NVL(f_round(c.iconcep * v_nfactor2, pcmoneda), 0));
            vimprec :=
                 NVL (f_segprima (psseguro, pffejecu), 0)
               * (  NVL (                      -- 81. 0030545: 10429 - Inicial
                         ABS (vfgracia_poliza - vfanula)
                                                        -- 81. 0030545: 10429 - Final
                         , 0)
                  / 365
                 );
            vtraza := 950;

             -- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596 - Inicio
            -- vrevocable := NVL(pac_parametros.f_parproducto_n(vsproduc, 'REVOCABLE'), 0);----se comenta por que no aplica restriccion por el momento para productos de confianza
            -- vtraza := 955;

            -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Final

            -- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596 - Final
            IF     vfgracia_poliza >= vfanula
               -- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596 - Inicio
                      -- AND vrevocable = 1--se comenta por que no aplica restriccion por el momento para productos de confianza
               -- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596 - Final
               AND NVL (ROUND (vimprec, 2), 0) >=
                                                NVL (ROUND (vimpfactor, 2), 0)
            THEN
               -- la fecha de anulacion de la poliza debe ser la fecha de gracia de la poliza
               vtraza := 956;
               -- vfanula_poliza := vfgracia_poliza; --PARA EL CLIENTE CONFIANZA LA FECHA DE GENERACION DEL NUEVO RECIBO Y DE ANULACION DEL ANERIOR DEBE SER LA MISMA QUE SE GENERE EL PROCESO DE ANULACION X NO PAGO
               vfanula_poliza := pffejecu;
               vtraza := 960;
               -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Inicial
                   -- Se subio por duplicado aqu? el 1er "pac_devolu.anula_poliza" para que se ejecute antes
                   -- de crear recibos de tiempo transcurrido, porque necesitan el NMOVIMI de la anulaci?n.
                   -- As? la rehabilitaci?n sabr? tratarlos. (

               -- 81. 0030545: 10429 - Inicio

               -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Inici
               --Ini IAXIS 3592 -- 27/05/2017
--               p_tab_error (f_sysdate,
--                            f_user,
--                            vproceso,
--                            vtraza,
--                               ' psseguro='
--                            || psseguro
--                            || ' error1:'
--                            || num_err
--                            || 'vfgracia_poliza -->'
--                            || vfgracia_poliza
--                            || ' vfanula-->'
--                            || vfanula
--                            || ' vnrecibo_aux-->'
--                            || vnrecibo_aux
--                            || ' pffejecu--> '
--                            || pffejecu,
--                            SQLERRM
--                           );
               num_err :=
                  pac_devolu.f_anula_poliza (psseguro,
                                             vfanula_poliza,
                                             pcmotivo
                                            );

               IF num_err <> 0
               THEN
                  RAISE accion_error;
               END IF;

               vtraza := 964;
               -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Inici
               --Ini IAXIS 3592 -- 27/05/2017
--               p_tab_error (f_sysdate,
--                            f_user,
--                            vproceso,
--                            vtraza,
--                               ' psseguro='
--                            || psseguro
--                            || ' error1:'
--                            || num_err
--                            || 'vfgracia_poliza -->'
--                            || vfgracia_poliza
--                            || ' vfanula-->'
--                            || vfanula
--                            || ' vnrecibo_aux-->'
--                            || vnrecibo_aux
--                            || ' pffejecu--> '
--                            || pffejecu,
--                            SQLERRM
--                           );

               -- 81. 0030545: 10429 - Final

               -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Inicial
               SELECT MAX (nmovimi)
                 INTO vnmovimi_anul
                 FROM movseguro
                WHERE sseguro = psseguro;

               -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Final
               vtraza := 965;
               -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Inici
               --Ini IAXIS 3592 -- 27/05/2017
--               p_tab_error (f_sysdate,
--                            f_user,
--                            vproceso,
--                            vtraza,
--                               ' psseguro='
--                            || psseguro
--                            || ' error1:'
--                            || num_err
--                            || 'vfgracia_poliza -->'
--                            || vfgracia_poliza
--                            || ' vfanula-->'
--                            || vfanula
--                            || ' vnrecibo_aux-->'
--                            || vnrecibo_aux
--                            || ' pffejecu--> '
--                            || pffejecu,
--                            SQLERRM
--                           );
               vnrecibo_aux := NULL;
               num_err :=
                  pac_propio_conf.f_genera_contabilidad_recibo
                                                             (vcempres,
                                                              psseguro,
                                                              vnrecibo,
                                                              -- 64. 0010069 - Inicio
                                                              -- vfanula,
                                                              vfefecto,
                                                              -- 64. 0010069 - Final
                                                              vfvencim,
                                                              vfgracia_poliza,
                                                              -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Inicial
                                                              -- vnmovimi,
                                                              vnmovimi_anul,
                                                              -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Final
                                                              v_tipocert,
                                                              vcmoneda,
                                                              vnrecibo_aux,
                                                              3,
                                                              NULL,
                                                              1,
                                                              vsmovagr
                                                             -- 56. 0027378 - QT-7911
                                                             );

--Fin IAXIS 3592 -- 27/05/2017
               -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Fi

               -- 81. 0030545: 10429 - Inicial
               IF num_err <> 0
               THEN
                  RAISE accion_error;
               ELSE
-- Bug 13482: DEV -  Terminaci?n x no pago: generacion de recibo de retorno de tiempo transcurrido
                  IF pac_retorno.f_tiene_retorno (NULL,
                                                  psseguro,
                                                  vnmovimi_anul,
                                                  'SEG'
                                                 ) = 1
                  THEN
                     num_err :=
                        pac_retorno.f_generar_retorno (psseguro,
                                                       vnmovimi_anul,
                                                       vnrecibo_aux,
                                                       NULL
                                                      );
                  END IF;
               END IF;

               -- 81. 0030545: 10429 - Final
               vtraza := 970;
            -- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596 - Final

            -- 30. 0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - 0127366 - Fin
            ELSE
               vtraza := 980;
               -- la fecha de anulacion de la poliza deber ser la minima fecha de efecto de los recibos pendientes
               vfanula_poliza := vfanula;
               -- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596 - Final

               -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Inicial
                     -- Se subio por duplicado aqu? el 2o "pac_devolu.anula_poliza" para que se ejecute antes
                     -- de crear recibos de tiempo transcurrido, porque necesitan el NMOVIMI de la anulaci?n.
                     -- As? la rehabilitaci?n sabr? tratarlos. (
                 --Ini IAXIS 3592 -- 27/05/2017
               vnrecibo_aux := NULL;

               IF vfgracia_poliza > pffejecu
               THEN
                  vfgracia_poliza := pffejecu;
               END IF;

               num_err :=
                  pac_propio_conf.f_genera_contabilidad_recibo
                                                             (vcempres,
                                                              psseguro,
                                                              vnrecibo,
                                                              -- 64. 0010069 - Inicio
                                                              -- vfanula,
                                                              vfefecto,
                                                              -- 64. 0010069 - Final
                                                              vfvencim,
                                                              vfgracia_poliza,
                                                              -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Inicial
                                                              -- vnmovimi,
                                                              vnmovimi_anul,
                                                              -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Final
                                                              v_tipocert,
                                                              vcmoneda,
                                                              vnrecibo_aux,
                                                              3,
                                                              NULL,
                                                              1,
                                                              vsmovagr
                                                             -- 56. 0027378 - QT-7911
                                                             );

--Fin IAXIS 3592 -- 27/05/2017
               -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Fi

               -- 81. 0030545: 10429 - Inicial
               IF num_err <> 0
               THEN
                  RAISE accion_error;
               END IF;

               vtraza := 985;
               -- 81. 0030545: 10429 - Inicio
               num_err :=
                  pac_devolu.f_anula_poliza (psseguro,
                                             vfanula_poliza,
                                             pcmotivo
                                            );

               IF num_err <> 0
               THEN
                  RAISE accion_error;
               END IF;
            -- 81. 0030545: 10429 - Final

            -- 58. 0027644: No prorratear conceptos (14,86) en recibos tiempo transcurrido - QT-8596 - Final
            END IF;

            -- fin Bug 22084 - APD - 18/06/2012
            vtraza := 990;

            -- Bug 22084 - APD - 18/06/2012
            -- anula_poliza(psseguro, pffejecu, pcmotivo);
            --anula_poliza(psseguro, vfanula, pcmotivo);
            -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Inicial
            -- pac_devolu.anula_poliza(psseguro, vfanula_poliza, pcmotivo);
            -- Se comenta "pac_devolu.anula_poliza" y se sube para que se ejecute antes de crear
            -- recibos de tiempo transcurrido, porque necesitan el NMOVIMI de la anulaci?n.
            -- As? la rehabilitaci?n sabr? tratarlos.
            -- 76. 0029431  Rehabilitaci?n anule recibos (ctiprec = 14) - Inicial

            --Se env?a la emisi?n del recibo a la ERP antes del cobro
            IF NVL (pac_parametros.f_parempresa_n (vcempres,
                                                   'GESTIONA_COBPAG'),
                    0
                   ) = 1
            THEN
               num_err :=
                  pac_ctrl_env_recibos.f_proc_recpag_mov (vcempres,
                                                          psseguro,
                                                          vnmovimi,
                                                          4,
                                                          NULL
                                                         );

               IF num_err != 0
               THEN
                  RAISE accion_error;
               END IF;
            END IF;
         -- fin Bug 22084 - APD - 18/06/2012
         END IF;
      END IF;

      vtraza := 1110;
      RETURN (num_err);
   EXCEPTION
      WHEN accion_error
      THEN
         -- 64. 0010069 - Inicio
         p_tab_error (f_sysdate,
                      f_user,
                      vproceso,
                      vtraza,
                         ' psseguro='
                      || psseguro
                      || ' error1:'
                      || num_err
                      || ' error2: 9903215',
                      SQLERRM
                     );
         num_err := 9903215;
         RETURN num_err;
      WHEN OTHERS
      THEN
         -- 81. 0030545: 10429 - Inicio
         p_tab_error (f_sysdate,
                      f_user,
                      vproceso,
                      vtraza,
                         ' psseguro='
                      || psseguro
                      || ' error1:'
                      || num_err
                      || ' daerror2: 9903216',
                      SQLERRM
                     );
         p_tab_error (f_sysdate,
                      f_user,
                      vproceso,
                      vtraza,
                         ' psseguro='
                      || psseguro
                      || ' error1:'
                      || num_err
                      || ' error2: 9903216',
                      SQLERRM
                     );
         num_err := 9903216;
         RETURN num_err;
   END f_devolu_accion_7;

     /*************************************************************************
      FUNCTION f_genera_recibo
      Crea recibo en estado pendiente con cobro para las polizas anuladas que se pasaron del periodo de gracia para recibos anulados por no pago
     param pcempres IN : Id de empresa
     param psseguro IN : id_de seguro
     param pnrecibo IN : id de recibo
     param pfefecto IN : fecha efecto de poliza
     param pfvencim IN : fecha vencimiento de poliza
     param pfgracia IN : fecha calculada del periodo de gracia
     param pnmovimi IN : id del movimiento de anulacion del recibo
     param ptipocert IN : tipo porcentaje
     param pcmoneda IN : moneda de seguro
     param pnrecibo_out : recibo de salida viene en NULL
     param pctiprec IN : tipo de recibo a crear
     param pnfactor IN : factor para realizar calculo de prorrata
     param pgasexp IN :
     param psmovagr IN :
   *************************************************************************/
   FUNCTION f_genera_recibo (
      pcempres       IN       NUMBER,                                     --24
      psseguro       IN       NUMBER,                                   --1623
      pnrecibo       IN       NUMBER,                              --900000501
      pfefecto       IN       DATE,
      pfvencim       IN       DATE,
      pfgracia       IN       DATE,
      pnmovimi       IN       NUMBER,
      ptipocert      IN       VARCHAR2,
      pcmoneda       IN       NUMBER,
      pnrecibo_out   OUT      NUMBER,
      pctiprec       IN       NUMBER,                                     --14
      pnfactor       IN       NUMBER,                                   --null
      pgasexp        IN       NUMBER,                                      --1
      psmovagr       IN       NUMBER                                       --0
            DEFAULT 0
   --56. 0027378: LCOL_A005-Error en terminaciones por no pago ... - QT-7911
   )
      RETURN NUMBER
   IS
      vobjeto          VARCHAR2 (100)    := 'pac_propio_conf.f_genera_recibo';
      vtraza           NUMBER;
      num_err          NUMBER;
      salir            EXCEPTION;
      vnrecibo_aux     recibos.nrecibo%TYPE;
      vnrecibo_aux_1   recibos.nrecibo%TYPE;
      vnrecibo_aux_2   recibos.nrecibo%TYPE;
      v_nfactor        NUMBER;
      v_sproces        NUMBER                     := 1;
      vdecimals        NUMBER;
      reg_seg          seguros%ROWTYPE;
      vfvencim         DATE;
      -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento
      vsmovagr         NUMBER                     := psmovagr;
      -- 56. 0027378: LCOL_A005-Error en terminaciones por no pago ... - QT-7911
      vnliqmen         NUMBER;
      vnliqlin         NUMBER;
      vcdelega         NUMBER;
      vproceslin       procesoslin.tprolin%TYPE;
      vextorn          NUMBER;                       -- 58. 0027644 - QT-8596
      v_nfactor2       NUMBER;                       -- 58. 0027644 - QT-8596
      vfactorx         NUMBER;                       -- 58. 0027644 - QT-8596
      vfmovini         DATE;                                   -- 64. 0010069
   BEGIN
      vtraza := 1;

      SELECT *
        INTO reg_seg
        FROM seguros
       WHERE sseguro = psseguro;

      -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc)
           INTO vdecimals
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 104347;              -- Producte no trobat a PRODUCTOS
            RAISE salir;
         WHEN OTHERS
         THEN
            num_err := 102705;                -- Error al llegir de PRODUCTOS
            RAISE salir;
      END;

      vtraza := 2;

      BEGIN
         /*
          {Creamos el recibo de tipo 14.-Tiempo transcurrido}
         */

         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Inicio
         --vfvencim := NVL(pfgracia, pfvencim);--19/06/17
         vfvencim := NVL (f_sysdate, pfvencim);                    --24/08/17

         --IF vfvencim <= pfefecto THEN
         IF vfvencim <= f_sysdate
         THEN                                --24/08/2017 DVA prorrata recibo
            -- vfvencim := f_sysdate + (pfvencim-pfefecto);--para mantener el mismo tiempo de vencimiento que tenia el recibo inicial
            vfvencim := f_sysdate + 30;
--se suma treinta respecto a lo solicitado por el usuario Yulieth Escobar de Confianza. 25/08/2017
         END IF;

         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Fin

         -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Inici
         num_err :=
            f_insrecibo (psseguro,
                         NULL,
                         f_sysdate
                                  --, pfefecto -- en confianza no se ingresa la fecha efecto del anteior recibo, esta se cambia por la fecha que se anula el recibo por no pago
            ,
                         f_sysdate,
                         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Inicio
                         -- NVL(pfgracia, pfvencim),
                         vfvencim,
                         -- 44. 0026314: LCOL_A003-Recibos con fecha efecto igual a fecha vencimiento - Fin
                         pctiprec,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         vnrecibo_aux,
                         'R',
                         NULL,
                         NULL,
                         pnmovimi,
                         f_sysdate,
                         ptipocert
                        );

         -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Fi
         /*
                 {El error 103108 , es un error controlado se genera el recibo}
         */
         IF num_err NOT IN (0, 103108)
         THEN
            RAISE salir;
         END IF;

         vtraza := 3;
      /*
      {borramos todos los conceptos}
      */
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 105156;
            RAISE salir;
      END;

      vtraza := 4;

       /*
        {Se busca el factor de prorrateo}
       */
      -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Inici
      IF pnfactor IS NULL
      THEN
         v_nfactor := (pfgracia - pfefecto) / (pfvencim - pfefecto);
      ELSE
         v_nfactor := pnfactor;
      END IF;

      vtraza := 5;
      -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Fi
      /*
      {recuperamos y grabamos los conceptos del recibos a }
      */

      -- 26. 0023864/0124752 - 02/10/2012 - JGR - Inicio
      /*
      FOR c IN (SELECT r.nrecibo, d.cconcep, d.cgarant, NVL(d.nriesgo, 1) nriesgo,
                       DECODE(ctiprec, 9, -d.iconcep, d.iconcep) iconcep
                  FROM detrecibos d, recibos r
                 WHERE d.nrecibo = r.nrecibo
                   AND r.nrecibo = pnrecibo) LOOP
         -- Los gastos de expedicion (cconcep = 14) no se deben prorratear
      */

      --
      -- 58. 0027644: No se ha de prorratear los conceptos de 14 y 86 en los recibos de tiempo transcurrido - QT-8596 - Inicio
      vextorn := 1;

      IF v_nfactor < 1
      THEN
         vextorn :=
            pac_anulacion.f_concep_retorna_anul (psseguro,
                                                 pnmovimi,
                                                 reg_seg.sproduc,
                                                 14,
                                                 reg_seg.fanulac,
                                                 vfactorx,
                                                 321
                                                );

         --  14 Gastos de expedición
         --  86 IVA - Gastos de expedición

         --> Devuelve 0 si concepto 14 es retornable, quiere decir que NO lo ha de pagar el cliente,
         --> el nuevo recibo si es prorratedo NO ha de tener conceptos 14 y 86

         --> Devuelve 1 y el recibo es prorrateado SÍ tendrá els 100% de la prima en los conceptos 14 y 86.
         IF vextorn NOT IN (0, 1)
         THEN
            num_err := vextorn;
            RAISE salir;
         END IF;
      END IF;

      -- 58. 0027644: No se ha de prorratear los conceptos de 14 y 86 en los recibos de tiempo transcurrido - QT-8596 - Final
      FOR c IN (SELECT r.nrecibo, d.cconcep, d.cgarant,
                       NVL (d.nriesgo, 1) nriesgo,
                       DECODE (ctiprec, 9, -d.iconcep, d.iconcep) iconcep
                  FROM detrecibos d, recibos r
                 WHERE d.nrecibo = r.nrecibo
                   AND r.nrecibo = pnrecibo
                   AND d.cconcep NOT IN (
                          SELECT ir.cconcep
                            FROM imprec ir
                           WHERE ir.ctipcon = 2
                             AND reg_seg.cramo = ir.cramo
                             AND reg_seg.cmodali = ir.cmodali
                             AND reg_seg.ctipseg = ir.ctipseg
                             AND reg_seg.ccolect = ir.ccolect
                             AND ir.cforpag = reg_seg.cforpag))
      LOOP
         vtraza := 6;

         BEGIN
            -- Los concepto 14 y 86, cuando toca incluirlos (vextorn = 1) no se prorratean, vextorn = 0 no los grabaremos
            IF c.cconcep IN (14, 86)
            THEN
               -- v_nfactor2 := vextorn;   --> vextorn solo puede ser 0 ó 1
               v_nfactor2 := 1;
            ELSE
               v_nfactor2 := v_nfactor;
            END IF;

            /*ACTUALIZA LOS CONCEPTOS DEL RECIBO IMAGEN DEL ANULADO CON LOS VALORES DEL TIEMPO TRANSCURRIDO*/
            IF v_nfactor2 != 0
            THEN
               INSERT INTO detrecibos
                           (nrecibo, cconcep, cgarant, nriesgo,
                            iconcep
                           )
                    VALUES (vnrecibo_aux, c.cconcep, c.cgarant, c.nriesgo,
                            NVL (f_round (c.iconcep * v_nfactor2, pcmoneda),
                                 0)
                           );
            END IF;
         -- 58. 0027644 - QT-8596 - Final

         -- 26. 0023864/0124752 - 02/10/2012 - JGR - Fin
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               BEGIN
                  vtraza := 10;

                  UPDATE detrecibos
                     SET iconcep =
                              iconcep
                            + f_round (c.iconcep
                                                         -- 26. 0023864/0124752 - 02/10/2012 - Inicio
                                                         --           * DECODE(c.cconcep, 14, 1 * pgasexp, v_nfactor),
                                                -- 58. 0027644 - QT-8596 - Inicio
                                                -- * v_nfactor,
                                       * v_nfactor2,
                                       -- 58. 0027644 - QT-8596 - Final
                                       -- 26. 0023864/0124752 - 02/10/2012 - Fin
                                       pcmoneda)
                   WHERE nrecibo = vnrecibo_aux
                     AND cconcep = c.cconcep
                     AND cgarant = c.cgarant
                     AND nriesgo = c.nriesgo;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     num_err := 104377;
                     RAISE salir;
               --{ error al modificar recibos}
               END;
            WHEN OTHERS
            THEN
               num_err := 103513;         --{error al insertar en detrecibos}
               RAISE salir;
         END;
      END LOOP;

      vtraza := 20;

      -- 26. 0023864/0124752 - 02/10/2012 - JGR - Inicio
      FOR c IN (SELECT r.nrecibo, d.cconcep, d.cgarant,
                       NVL (d.nriesgo, 1) nriesgo,
                       DECODE (ctiprec, 9, -d.iconcep, d.iconcep) iconcep
                  FROM detrecibos d, recibos r
                 WHERE d.nrecibo = r.nrecibo
                   AND r.nrecibo = pnrecibo
                   AND d.cconcep IN (
                          SELECT ir.cconcep
                            FROM imprec ir
                           WHERE ir.ctipcon = 2
                             AND reg_seg.cramo = ir.cramo
                             AND reg_seg.cmodali = ir.cmodali
                             AND reg_seg.ctipseg = ir.ctipseg
                             AND reg_seg.ccolect = ir.ccolect
                             AND ir.cforpag = reg_seg.cforpag))
      LOOP
         vtraza := 30;

         BEGIN
            -- 58. 0027644 - QT-8596 - Inicio
            -- Los concepto 14 y 86, cuando toca incluirlos (vextorn = 1) no se prorratean, vextorn = 0 no los grabaremos
            IF c.cconcep IN (14, 86)
            THEN
               -- v_nfactor2 := vextorn;   --> vextorn solo puede ser 0 ó 1
               v_nfactor2 := 1;
            ELSE
               v_nfactor2 := pgasexp;
            END IF;

            IF v_nfactor2 != 0
            THEN
               INSERT INTO detrecibos
                           (nrecibo, cconcep, cgarant, nriesgo,
                            iconcep
                           )
                    VALUES (vnrecibo_aux, c.cconcep, c.cgarant, c.nriesgo,
                            f_round (c.iconcep * v_nfactor2, pcmoneda)
                           );
            END IF;
         -- 58. 0027644 - QT-8596 - Final
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               BEGIN
                  vtraza := 40;

                  UPDATE detrecibos
                     SET iconcep =
                             iconcep + f_round (c.iconcep * pgasexp, pcmoneda)
                   WHERE nrecibo = vnrecibo_aux
                     AND cconcep = c.cconcep
                     AND cgarant = c.cgarant
                     AND nriesgo = c.nriesgo;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     num_err := 104377;
                     RAISE salir;
               --{ error al modificar recibos}
               END;
            WHEN OTHERS
            THEN
               num_err := 103513;         --{error al insertar en detrecibos}
               RAISE salir;
         END;
      END LOOP;

      -- 26. 0023864/0124752 - 02/10/2012 - JGR - Fin
      vtraza := 50;                                                       -- 7

       /*
      { restauramos los totales del recibo}
      */
      -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      DELETE FROM vdetrecibos_monpol
            WHERE nrecibo = vnrecibo_aux;

      vtraza := 60;                                                       -- 8

      -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      DELETE      vdetrecibos
            WHERE nrecibo = vnrecibo_aux;

      vtraza := 70;                                                       -- 9
      num_err := f_vdetrecibos ('R', vnrecibo_aux);

      IF num_err != 0
      THEN
         RAISE salir;
      END IF;

      -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Inicial
      -- Generamos el corretaje del recibo
      vtraza := 75;                                                     -- 9,5

      IF pac_corretaje.f_tiene_corretaje (psseguro, NULL) = 1
      THEN
-- Bug 30548 10/03/2014, se elimina el pnmovimi, se envia a NUL para que busque si tiene co-corretaje
         num_err :=
            pac_corretaje.f_reparto_corretaje (psseguro,
                                               pnmovimi,
                                               vnrecibo_aux
                                              );
      END IF;

      IF num_err != 0
      THEN
         RAISE salir;
      END IF;

      -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Final
      vtraza := 80;                                                      -- 10
      num_err :=
         pac_cesionesrea.f_cessio_det (v_sproces,
                                       psseguro,
                                       vnrecibo_aux,
                                       reg_seg.cactivi,
                                       reg_seg.cramo,
                                       reg_seg.cmodali,
                                       reg_seg.ctipseg,
                                       reg_seg.ccolect,
                                       pfefecto,
                                       pfgracia,
                                       1,
                                       vdecimals
                                      );

      IF num_err != 0
      THEN
         RAISE salir;
      END IF;

      vtraza := 90;
      pnrecibo_out := vnrecibo_aux;
      -- Ini 26719 -- ECP -- 15/04/2013
      vtraza := 100;

      -- 49. 0026719: LCOL_A001-Incidencias en proceso de terminaciones por no pago. - 0145148 - Inicio
      -- Solo se puede permitir la anulación si el recibo está pendiente 0, ni remesado 3
      IF f_cestrec (pnrecibo, NULL) = 0
      THEN
         vtraza := 110;

         -- 49. 0026719: LCOL_A001-Incidencias en proceso de terminaciones por no pago. - 0145148 - Final

         -- 64. 0010069 - Final
         SELECT GREATEST (fmovini, pfgracia)
           INTO vfmovini
           FROM movrecibo
          WHERE nrecibo = pnrecibo AND fmovfin IS NULL;

         p_tab_error (f_sysdate,
                      f_user,
                      'f_genera_recibo',
                      1,
                      1,
                         SQLCODE
                      || ' - '
                      || SQLERRM
                      || ' pnrecibo-->'
                      || pnrecibo
                      || ' pfgracia-->'
                      || pfgracia
                      || ' vsmovagr-->'
                      || vsmovagr
                      || ' vnliqmen-->'
                      || vnliqmen
                      || ' vnliqlin-->'
                      || vnliqlin
                      || '  vcdelega-->'
                      || vcdelega
                      || '  vcdelega-->'
                      || vcdelega
                     );
         vtraza := 120;
         num_err :=
            f_movrecibo (pnrecibo,
                         2,
                         pfgracia,
                         2,
                         vsmovagr,
                         vnliqmen,
                         vnliqlin,
                         vfmovini,
                         NULL,
                         vcdelega,
                         -- 76. 0029431  Rehabilitación anule recibos (ctiprec = 14) - Inicio
                         -- NULL,
                         321,                                      -- pcmotmov
                         -- 76. 0029431  Rehabilitación anule recibos (ctiprec = 14) - Final
                         NULL
                        );

         -- 64. 0010069 - Final
         IF num_err != 0
         THEN
            RAISE salir;
         END IF;
      END IF;

      -- Fin 26719 -- ECP -- 15/04/2013
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_conf.f_genera_recibo',
                      vtraza,
                      num_err,
                      f_axis_literales (num_err)
                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         num_err := 1000455;                          -- Error no controlado.
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_conf.f_genera_recibo',
                      vtraza,
                      num_err,
                      SQLERRM
                     );
         RETURN num_err;
   END f_genera_recibo;

   -- Ini IAXIS/3592 -- 28/05/2019
   FUNCTION f_genera_contabilidad_recibo (
      pcempres       IN       NUMBER,                                     --24
      psseguro       IN       NUMBER,                                   --1623
      pnrecibo       IN       NUMBER,                              --900000501
      pfefecto       IN       DATE,
      pfvencim       IN       DATE,
      pfgracia       IN       DATE,
      pnmovimi       IN       NUMBER,
      ptipocert      IN       VARCHAR2,
      pcmoneda       IN       NUMBER,
      pnrecibo_out   OUT      NUMBER,
      pctiprec       IN       NUMBER,                                     --14
      pnfactor       IN       NUMBER,                                   --null
      pgasexp        IN       NUMBER,                                      --1
      psmovagr       IN       NUMBER                                       --0
            DEFAULT 0
   )
      RETURN NUMBER
   IS
      vobjeto           VARCHAR2 (100)
                            := 'pac_propio_conf.f_genera_contabilidad_recibo';
      vtraza            NUMBER;
      num_err           NUMBER;
      salir             EXCEPTION;
      vnrecibo_aux      recibos.nrecibo%TYPE;
      vnrecibo_aux_1    recibos.nrecibo%TYPE;
      vnrecibo_aux_2    recibos.nrecibo%TYPE;
      v_nfactor         NUMBER;
      v_sproces         NUMBER                     := 1;
      vdecimals         NUMBER;
      reg_seg           seguros%ROWTYPE;
      vfvencim          DATE;
      vsmovagr          NUMBER                     := psmovagr;
      vnliqmen          NUMBER;
      vnliqlin          NUMBER;
      vcdelega          NUMBER;
      vproceslin        procesoslin.tprolin%TYPE;
      vextorn           NUMBER;
      v_nfactor2        NUMBER;
      vfactorx          NUMBER;
      vfmovini          DATE;
      vnmovimi          NUMBER;
      lpago             NUMBER;
      vcdivisa          NUMBER;
      vigenera          NUMBER                     := 0;
      vfcobros          DATE;
      vitasa            NUMBER;
      vn_moneinst       NUMBER;
      viconcep          NUMBER;
      viconcep_monpol   NUMBER;
      vsmovrec          NUMBER;
      viimporte         NUMBER;
      vnorden           NUMBER                     := 1;
      vitotalr          NUMBER;
      vterror           VARCHAR2 (2000);
      vtipopago         NUMBER                     := 4;
      vemitido          NUMBER;
      vsinterf          NUMBER;
      perror            VARCHAR2 (250);
      vterminal         VARCHAR2 (20);
      vmonprod          NUMBER;
      v_conta           NUMBER;
      --Ini IAXIS-5149  --ECP --14/09/2019
      v_factor_com      NUMBER;
      vdcancela         NUMBER;
      vabonos           NUMBER;
      vabonose          NUMBER;
      --Ini IAXIS-5149  --ECP --03/12/2019
      vrecibo           NUMBER                     := 0;
      vreciboe          NUMBER                     := 0;
      --Ini IAXIS-5149  --ECP --31/02/2020
      lpagoe            NUMBER;

      CURSOR c_com
      IS
         SELECT c.nrecibo, c.cagente, c.nnumcom, c.cgarant, c.ccompan
           FROM comrecibo c, recibos re
          WHERE c.nrecibo = re.nrecibo
            AND c.nrecibo = pnrecibo
            AND c.nmovimi = (SELECT MAX (d.nmovimi)
                               FROM comrecibo d
                              WHERE d.nrecibo = c.nrecibo);
   BEGIN
      vtraza := 1;

      IF f_cestrec (pnrecibo, NULL) = 0
      THEN
         SELECT *
           INTO reg_seg
           FROM seguros
          WHERE sseguro = psseguro;

         -- 19292: CRE800 - Rebuts d'extorn i cessions (AXIS3186) - Inici
         BEGIN
            SELECT pac_monedas.f_moneda_producto (sproduc), cdivisa
              INTO vmonprod, vcdivisa
              FROM productos
             WHERE cramo = reg_seg.cramo
               AND cmodali = reg_seg.cmodali
               AND ctipseg = reg_seg.ctipseg
               AND ccolect = reg_seg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               num_err := 104347;           -- Producte no trobat a PRODUCTOS
               RAISE salir;
            WHEN OTHERS
            THEN
               num_err := 102705;             -- Error al llegir de PRODUCTOS
               RAISE salir;
         END;

         SELECT f_parinstalacion_n ('MONEDAINST')
           INTO vn_moneinst
           FROM DUAL;

         -- Ini IAXIS-5149 --ECP-- 24/09/2019
         vitasa :=
            NVL
               (pac_eco_tipocambio.f_cambio
                                        (pac_monedas.f_cmoneda_t (vmonprod),
                                         pac_monedas.f_cmoneda_t (vn_moneinst),
                                         reg_seg.fefecto
                                        ),
                1
               );
         -- Fin IAXIS-5149 --ECP-- 24/09/2019
         vtraza := 2;
         --24/08/2017 DVA prorrata recibo
         vfvencim :=
              reg_seg.fefecto
            + NVL (pac_parametros.f_parproducto_n (reg_seg.sproduc,
                                                   'DIAS_CONVENIO_RNODOM'
                                                  ),
                   0
                  );
         vtraza := 3;

         /*
          {Se busca el factor de prorrateo}
         */

         -- Bug 23638: JRV -  LCOL_A001- Terminaci?n x no pago: error en els rebuts prorratejats  - Fi
         /*
         {recuperamos y grabamos los conceptos del recibos a }

         */
         BEGIN
            SELECT MAX (smovrec)
              INTO vsmovrec
              FROM movrecibo
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vsmovrec := smovrec.NEXTVAL;
         END;

         FOR c IN
            ((SELECT   nrecibo, cconcep, cgarant, nriesgo,
                       SUM (iconcep) iconcep,
                       SUM (iconcep_monpol) iconcep_monpol, nmovima
                  FROM (SELECT   r.nrecibo, d.cconcep,
                                 DECODE (d.cgarant,
                                         NULL, g.cgarant,
                                         d.cgarant
                                        ) cgarant,
                                 NVL (d.nriesgo, 1) nriesgo,
                                 SUM (DECODE (ctiprec,
                                              9, m.iconcep,
                                              -m.iconcep
                                             )
                                     ) iconcep,
                                 SUM
                                    (DECODE (ctiprec,
                                             9, m.iconcep_monpol,
                                             -m.iconcep_monpol
                                            )
                                    ) iconcep_monpol,
                                 d.nmovima
                            FROM detrecibos d,
                                 recibos r,
                                 garanseg g,
                                 detmovrecibo_parcial m
                           WHERE d.nrecibo = r.nrecibo
                             AND m.nrecibo = r.nrecibo
                             AND m.cconcep = d.cconcep
                             AND g.cgarant = m.cgarant
                             AND d.cgarant = m.cgarant
                             AND r.nrecibo = pnrecibo
                             AND d.nmovima = (SELECT MAX (e.nmovima)
                                                FROM detrecibos e
                                               WHERE e.nrecibo = d.nrecibo)
                             AND g.sseguro = r.sseguro
                             AND g.ffinefe IS NULL
                             AND m.nreccaj IS NOT NULL
                        GROUP BY r.nrecibo,
                                 d.cconcep,
                                 d.cgarant,
                                 g.cgarant,
                                 d.nriesgo,
                                 d.nmovima
                        UNION
                        SELECT   r.nrecibo, d.cconcep,
                                 DECODE (d.cgarant,
                                         NULL, g.cgarant,
                                         d.cgarant
                                        ) cgarant,
                                 NVL (d.nriesgo, 1) nriesgo,
                                 SUM (DECODE (ctiprec,
                                              9, -d.iconcep,
                                              d.iconcep
                                             )
                                     ) iconcep,
                                 SUM
                                    (DECODE (ctiprec,
                                             9, -d.iconcep_monpol,
                                             d.iconcep_monpol
                                            )
                                    ) iconcep_monpol,
                                 d.nmovima
                            FROM detrecibos d, recibos r, garanseg g
                           WHERE d.nrecibo = r.nrecibo
                             AND r.nrecibo = pnrecibo
                             AND d.nmovima = (SELECT MAX (e.nmovima)
                                                FROM detrecibos e
                                               WHERE e.nrecibo = d.nrecibo)
                             AND g.sseguro = r.sseguro
                             AND g.ffinefe IS NULL
                        GROUP BY r.nrecibo,
                                 d.cconcep,
                                 d.cgarant,
                                 g.cgarant,
                                 d.nriesgo,
                                 d.nmovima)
              GROUP BY nrecibo, cconcep, cgarant, nriesgo, nmovima))
         -- Fin IAXIS-5149 --ECP-- 03/12/2019
         LOOP
            vtraza := 6;

            IF pnfactor IS NULL
            THEN
               IF c.cconcep NOT IN (14, 86)
               THEN
                  vtraza := 61;
                  vdcancela :=
                           ROUND (TRUNC (f_sysdate) - TRUNC (reg_seg.fefecto));

--                  p_tab_error (f_sysdate,
--                         f_user,
--                         'f_genera_contabilidad_rec_1',
--                         vtraza,
--                         vtraza,
--                            SQLCODE
--                         || ' - '
--                         || SQLERRM
--                         || 'poliza'
--                         || reg_seg.npoliza
--                         || ' pnrecibo-->'
--                         || pnrecibo
--                         || ' pfgracia-->'
--                         || pfgracia
--                         || ' v_nfactor -->'
--                         || v_nfactor
--                         || ' vdcancela-->'
--                         || vdcancela
--                         || ' vdcancela/-->'
--                         || vdcancela /  (trunc(reg_seg.fvencim) - trunc(reg_seg.fefecto))
--                         || ' (reg_seg.fvencim - reg_seg.fefecto)'
--                         || (trunc(reg_seg.fvencim) - trunc(reg_seg.fefecto))
--                         || ' vnliqlin-->'
--                         || vnliqlin
--                         || ' vfmovini-->'
--                         || vfmovini
--                         || ' v_factor_com->'
--                         || v_factor_com
--                         || ' vitasa->'
--                         || vitasa
--                         || 'reg_seg.fefecto -->'
--                         || reg_seg.fefecto
--                        );
                  IF (NVL
                         (pac_parametros.f_parproducto_n
                                                       (reg_seg.sproduc,
                                                        'DIAS_CONVENIO_RNODOM'
                                                       ),
                          0
                         ) < vdcancela
                     )
                  THEN
                     vtraza := 64;
                     v_nfactor :=
                          NVL
                             (pac_parametros.f_parproducto_n
                                                       (reg_seg.sproduc,
                                                        'DIAS_CONVENIO_RNODOM'
                                                       ),
                              0
                             )
                        / (TRUNC (reg_seg.fvencim) - TRUNC (reg_seg.fefecto));
                  ELSE
                     vtraza := 63;
                     v_nfactor :=
                          vdcancela
                        / (TRUNC (reg_seg.fvencim) - TRUNC (reg_seg.fefecto));
                  END IF;

                  vtraza := 62;
                  v_factor_com := -v_nfactor;
               ELSE
                  v_nfactor := 1;
               END IF;
            ELSE
               v_nfactor := pnfactor;
            END IF;

--            p_tab_error (f_sysdate,
--                         f_user,
--                         'f_genera_contabilidad_rec_1',
--                         vtraza,
--                         vtraza,
--                            SQLCODE
--                         || ' - '
--                         || SQLERRM
--                         || 'poliza'
--                         || reg_seg.npoliza
--                         || ' pnrecibo-->'
--                         || pnrecibo
--                         || ' pfgracia-->'
--                         || pfgracia
--                         || ' v_nfactor -->'
--                         || v_nfactor
--                         || ' vdcancela-->'
--                         || vdcancela
--                         || ' vdcancela/-->'
--                         || vdcancela / (reg_seg.fvencim - reg_seg.fefecto)
--                         || ' (reg_seg.fvencim - reg_seg.fefecto)'
--                         ||  (trunc(reg_seg.fvencim) - trunc(reg_seg.fefecto))
--                         || ' vnliqlin-->'
--                         || vnliqlin
--                         || ' vfmovini-->'
--                         || vfmovini
--                         || ' v_factor_com->'
--                         || v_factor_com
--                         || ' vitasa->'
--                         || vitasa
--                         || 'reg_seg.fefecto -->'
--                         || reg_seg.fefecto
--                        );
            BEGIN
               -- Ini IAXIS-5149 -- 06/12/2019
               BEGIN
                  SELECT NVL (SUM (iconcep_monpol), 0),
                         NVL (SUM (iconcep), 0)
                    INTO vabonos,
                         vabonose
                    FROM detmovrecibo_parcial
                   WHERE nrecibo = pnrecibo
                     AND cconcep = c.cconcep
                     AND cgarant = c.cgarant
                     AND nreccaj IS NOT NULL;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     vabonos := 0;
                     vabonose := 0;
               END;

--                    p_tab_error (f_sysdate,
--                                     f_user,
--                                     'f_genera_contabilidad_rec_1',
--                                     vtraza,
--                                     vtraza,
--                                        SQLCODE
--                                     || ' - '
--                                     || SQLERRM
--                                     || ' despues --pnrecibo-->'
--                                     || pnrecibo
--                                     || ' pfgracia-->'
--                                     || pfgracia
--                                     || ' v_nfactor -->'
--                                     || v_nfactor
--                                     || ' vabonos-->'
--                                     || vabonos
--                                     || ' vabonose-->'
--                                     || vabonose
--                                     || ' viconcep_monpol-->'
--                                     || viconcep_monpol
--                                     || ' vrecibo-->'
--                                     || vrecibo
--                                    );
                  -- Fin IAXIS-5149 -- 06/12/2019
               lpago :=
                         (c.iconcep_monpol + NVL (vabonos, 0))
                       * (1 - v_nfactor);
               lpagoe := (c.iconcep + NVL (vabonose, 0)) * (1 - v_nfactor);
               viconcep := NVL (f_round (lpagoe), 0);
               viconcep_monpol := NVL (f_round (lpago), 0);
               vnmovimi := c.nmovima;

--               p_tab_error (f_sysdate,
--                            f_user,
--                            'f_genera_contabilidad_rec_1',
--                            vtraza,
--                            vtraza,
--                               SQLCODE
--                            || ' - '
--                            || SQLERRM
--                            || ' pnrecibo-->'
--                            || pnrecibo
--                            ||'c.cconcep -->'
--                            ||c.cconcep
--                            ||'c.iconcep -->'
--                            ||c.iconcep
--                            ||'viconcep -->'
--                            ||viconcep
--                            || ' pfgracia-->'
--                            || pfgracia
--                            || ' v_nfactor -->'
--                            || v_nfactor
--                            || ' vabonos-111->'
--                            || vabonos
--                            || ' viconcep_monpol-->'
--                            || viconcep_monpol
--                            || ' vitasa-->'
--                            || vitasa
--                           );

               /*BEGIN
                  INSERT INTO detrecibos
                              (nrecibo, cconcep, cgarant, nriesgo,
                               iconcep,
                               nmovima, iconcep_monpol, fcambio
                              )
                       VALUES (c.nrecibo, c.cconcep, c.cgarant, c.nriesgo,
                               NVL (f_round (c.iconcep, pcmoneda), 0),
                               vnmovimi + 1, NVL (f_round (c.iconcep_monpol, pcmoneda), 0), reg_seg.fefecto
                              );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     num_err := SQLERRM ;
               RAISE salir;
               END;*/
               IF vitasa = 1
               THEN
                  SELECT itotalr
                    INTO vitotalr
                    FROM vdetrecibos_monpol
                   WHERE nrecibo = pnrecibo;
               ELSE
                  SELECT itotalr
                    INTO vitotalr
                    FROM vdetrecibos
                   WHERE nrecibo = pnrecibo;
               END IF;

               viimporte := vitotalr;
               vtraza := 73;

--               p_tab_error (f_sysdate,
--                            f_user,
--                            'f_genera_contabilidad_rec_1',
--                            vtraza,
--                            vtraza,
--                               SQLCODE
--                            || ' - '
--                            || SQLERRM
--                            || ' pnrecibo-->'
--                            || pnrecibo
--                            || ' pfgracia-->'
--                            || pfgracia
--                            || ' concep -->'
--                            || c.cconcep
--                            || ' vabonos-->'
--                            || vabonos
--                            || ' viconcep_monpol-->'
--                            || viconcep_monpol
--                           );
               BEGIN
                  SELECT MAX (NVL (norden, 0)) + 1
                    INTO vnorden
                    FROM detmovrecibo
                   WHERE nrecibo = pnrecibo AND smovrec = vsmovrec;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     vnorden := 1;
               END;

               vtraza := 730;

--               p_tab_error (f_sysdate,
--                            f_user,
--                            'f_genera_contabilidad_rec_1',
--                            vtraza,
--                            vtraza,
--                               SQLCODE
--                            || ' - '
--                            || SQLERRM
--                            || ' pnrecibo-->'
--                            || pnrecibo
--                            || ' pfgracia-->'
--                            || pfgracia
--                            || ' concep -->'
--                            || c.cconcep
--                            || ' vabonos-->'
--                            || vabonos
--                            || ' viconcep_monpol-->'
--                            || viconcep_monpol
--                           );
               IF c.cconcep IN (0, 4, 14, 86)
               THEN
                  vrecibo :=
                       vrecibo
                     + f_round (  (c.iconcep_monpol + NVL (vabonos, 0))
                                * v_nfactor
                               );
                  vreciboe :=
                       vreciboe
                     + f_round (  (c.iconcep + NVL (vabonose, 0))
                                * v_nfactor
                                
                               );
               END IF;

               
               BEGIN
                  INSERT INTO detmovrecibo
                              (smovrec, norden, nrecibo,
                               iimporte, fmovimi, fefeadm, cusuari, sdevolu,
                               nnumnlin, cbancar1, nnumord, smovrecr,
                               nordenr, tdescrip, iimporte_moncon, sproces,
                               fcambio
                              )
                       VALUES (vsmovrec, NVL (vnorden, 1), pnrecibo,
                               ROUND (viconcep), f_sysdate, NULL, f_user, 0,
                               0, 0, 1, NULL,
                               NULL, NULL, ROUND (viconcep_monpol), NULL,
                               reg_seg.fefecto
                              );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_tab_error (f_sysdate,
                                  f_user,
                                  'f_genera_contabilidad_rec_1',
                                  vtraza,
                                  vtraza,
                                     SQLCODE
                                  || ' - '
                                  || SQLERRM
                                  || ' vsmovrec-->'
                                  || vsmovrec
                                  || 'vnordena-->'
                                  || vnorden
                                  || ' pnrecibo -->'
                                  || pnrecibo
                                  || ' viconcep-->'
                                  || viconcep
                                  || ' trunc viconcep-->'
                                  || TRUNC (viconcep)
                                  || ' round viconcep-->'
                                  || ROUND (viconcep)
                                  || ' viconcep_monpol-->'
                                  || viconcep_monpol
                                  || ' viconcep-->'
                                  || viconcep
                                  || ' reg_seg.fefecto'
                                  || reg_seg.fefecto
                                 );
                     num_err := SQLERRM;
                     RAISE salir;
               END;

                 
              
               vtraza := 74;

               BEGIN
                  INSERT INTO detmovrecibo_parcial
                              (smovrec, norden, nrecibo,
                               cconcep, cgarant, nriesgo,
                               iconcep, iconcep_monpol,
                               fcambio
                              )
                       VALUES (vsmovrec, NVL (vnorden, 1), pnrecibo,
                               c.cconcep, c.cgarant, c.nriesgo,
                               ROUND (viconcep), ROUND (viconcep_monpol),
                               reg_seg.fefecto
                              );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     num_err := SQLERRM;
                     RAISE salir;
               END;
            END;

            vtraza := 76;
         END LOOP;

         -- Ini IAXIS-5149 -- 20/09/2019
                -- Ini IAXIS-5149 -- 03/12/2019
         BEGIN
            SELECT NVL (SUM (iimporte_moncon), 0), NVL (SUM (iimporte), 0)
              INTO vabonos, vabonose
              FROM detmovrecibo
             WHERE nrecibo = pnrecibo AND nreccaj IS NOT NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vabonos := 0;
               vabonose:=0;
         END;

                    
                  -- Fin IAXIS-5149 -- 20/09/2019
         IF vabonos IS NOT NULL
         THEN               
            IF vabonos <> 0
            THEN
                  -- Ini IAXIS-5149 -- 18/12/2019
               IF vabonos >= vrecibo
               -- Fin IAXIS-5149 -- 18/12/2019
               THEN
                  num_err := 89907058;
                  p_tab_error (f_sysdate,
                               f_user,
                               'f_genera_contabilidad_rec_1',
                               vtraza,
                               vtraza,
                                  SQLCODE
                               || ' - '
                               || SQLERRM
                               || ' pnrecibo-->'
                               || pnrecibo
                               || ' pfgracia-->'
                               || pfgracia
                               || ' v_nfactor -->'
                               || v_nfactor
                               || ' vabonos-->'
                               || vabonos
                               || ' viconcep-->'
                               || viconcep
                               || ' viconcep_monpol-->'
                               || viconcep_monpol
                               || ' vrecibo-->'
                               || vrecibo
                               || ' vreciboe-->'
                               || vreciboe
                               || 'num_err '
                               || num_err
                              );
                  RAISE salir;
               END IF;
            END IF;
         END IF;

                -- Fin IAXIS-5149 -- 03/12/2019
-- Ini IAXIS-5149 --ECP-- 03/12/2019
--         p_tab_error (f_sysdate,
--                            f_user,
--                            'f_genera_contabilidad_rec_1',
--                            vtraza,
--                            vtraza,
--                               SQLCODE
--                            || ' - '
--                            || SQLERRM
--                            || 'antes  pnrecibo-->'
--                            || pnrecibo
--                            || ' pfgracia-->'
--                            || pfgracia
--                            || ' vabonos-->'
--                            || vabonos
--                            || ' viconcep_monpol-->'
--                            || viconcep_monpol
--                            || ' vrecibo-->'
--                            || vrecibo
--                           );
         FOR j IN c_com
         LOOP
            BEGIN
               SELECT COUNT (1)
                 INTO v_conta
                 FROM comrecibo a
                WHERE a.nrecibo = pnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_conta := 0;
            END;

            vtraza := 75;
            

            BEGIN
               INSERT INTO comrecibo
                           (nrecibo, nnumcom, cagente, cestrec, fmovdia,
                            fcontab, icombru, icomret, icomdev, iretdev,
                            nmovimi, icombru_moncia, icomret_moncia,
                            icomdev_moncia, iretdev_moncia, fcambio, cgarant,
                            ccompan, ivacomisi, icomcedida,
                            icomcedida_moncia)
                  SELECT a.nrecibo, a.nnumcom , a.cagente,
                         a.cestrec, reg_seg.fefecto, NULL,
                         ROUND (a.icombru * v_factor_com),
                         ROUND (a.icomret * v_factor_com),
                         ROUND (a.icomdev * v_factor_com),
                         ROUND (a.iretdev * v_factor_com), vnmovimi + 1,
                         ROUND (a.icombru_moncia * v_factor_com),
                         ROUND (a.icomret_moncia * v_factor_com),
                         ROUND (a.icomdev_moncia * v_factor_com),
                         ROUND (a.iretdev_moncia * v_factor_com),
                         reg_seg.fefecto, a.cgarant, a.ccompan,
                         NVL (ROUND (a.ivacomisi * v_factor_com), 0),
                         ROUND (icomcedida * v_factor_com),
                         ROUND (icomcedida_moncia * v_factor_com)
                    FROM comrecibo a
                   WHERE a.nrecibo = j.nrecibo
                     AND a.nnumcom = j.nnumcom
                     AND a.cagente = j.cagente
                     AND a.cgarant = j.cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  num_err := SQLERRM;
                  RAISE salir;
            END;
         END LOOP;

         --Ini IAXIS-5149  --ECP --24/09/2019
         vtraza := 20;

         IF num_err != 0
         THEN
            RAISE salir;
         END IF;

         -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Inicial
         -- Generamos el corretaje del recibo
         vtraza := 75;                                                  -- 9,5

         IF pac_corretaje.f_tiene_corretaje (psseguro, NULL) = 1
         THEN
-- Bug 30548 10/03/2014, se elimina el pnmovimi, se envia a NUL para que busque si tiene co-corretaje
            num_err :=
               pac_corretaje.f_reparto_corretaje (psseguro,
                                                  pnmovimi,
                                                  vnrecibo_aux
                                                 );
         END IF;

         IF num_err != 0
         THEN
            RAISE salir;
         END IF;

         -- 64. 0010069: VG CONTRIBUTIVO ERROR GENERACION DE RECIBOS AL SUBIR ASEGURADO - Final
         vtraza := 90;
         pnrecibo_out := vnrecibo_aux;
         vtraza := 110;

         SELECT fmovini
           INTO vfmovini
           FROM movrecibo
          WHERE nrecibo = pnrecibo AND fmovfin IS NULL;

         vtraza := 120;
         vsmovagr := psmovagr;
         -- Ini IAXIS-5149 -- ECP -- 30/08/2019
--         p_tab_error (f_sysdate,
--                      f_user,
--                      'f_genera_contabilidad_recibo',
--                      1,
--                      1,
--                         SQLCODE
--                      || ' - '
--                      || SQLERRM
--                      || ' pnrecibo-->'
--                      || pnrecibo
--                      || ' pfgracia-->'
--                      || pfgracia
--                      || ' vnmovimi-->'
--                      || vnmovimi
--                      || ' vsmovagr-->'
--                      || vsmovagr
--                      || ' vnliqmen-->'
--                      || vnliqmen
--                      || ' vnliqlin-->'
--                      || vnliqlin
--                      || ' vfmovini-->'
--                      || vfmovini
--                      || ' vcdelega-321->'
--                      || vcdelega
--                     );
         num_err :=
            f_movrecibo (pnrecibo,
                         3,
                         pfgracia,
                         vnmovimi,
                         vsmovagr,
                         vnliqmen,
                         vnliqlin,
                         vfmovini,
                         NULL,
                         vcdelega,
                         -- 76. 0029431  Rehabilitación anule recibos (ctiprec = 14) - Inicio
                         -- NULL,
                         321,                                      -- pcmotmov
                         -- 76. 0029431  Rehabilitación anule recibos (ctiprec = 14) - Final
                         NULL
                         --,
                        -- pcmreca      => 21
                        );
         -- Fin IAXIS-5149 -- ECP -- 30/08/2019
         num_err :=
            pac_user.f_get_terminal (pac_md_common.f_get_cxtusuario,
                                     vterminal);
         num_err :=
            pac_con.f_emision_pagorec (pcempres,
                                       1,
                                       4,
                                       pnrecibo,
                                       vsmovrec,
                                       vterminal,
                                       vemitido,
                                       vsinterf,
                                       perror,
                                       f_user,
                                       NULL,
                                       NULL,
                                       NULL,
                                       1
                                      );
         vtraza := 8;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_conf.f_genera_contabilidad_recibo',
                      vtraza,
                      num_err,
                      f_axis_literales (num_err)
                     );
      WHEN OTHERS
      THEN
         num_err := 1000455;                          -- Error no controlado.
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_propio_conf.f_genera_contabilidad_recibo',
                      vtraza,
                      num_err,
                      SQLERRM
                     );
   END f_genera_contabilidad_recibo;
-- Fin -- IAXIS/3592 -- 28/05/2019
END pac_propio_conf;
/