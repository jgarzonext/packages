CREATE OR REPLACE PACKAGE BODY PK_NUEVA_PRODUCCION AS
   /******************************************************************************
    NAME:       PK_NUEVA_PRODUCCION
    PURPOSE:

    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????  ???              1. Created this package body.
    2.0        11/03/2009  DRA              2. 0009216: IAX - Revisió de la gestió de garanties en la contractació
    3.0        18/03/2009  DRA              3. 0009523: IAX - Gestió de propostes: Error en la data de cartera anual a l'emetre una pòlissa prÃ¨viament retinguda
    4.0        01/04/2009  RSC              4. Adaptación iAxis a productos colectivos con certificados
    5.0        17/04/2009  APD              5. Bug 9699 - primero se ha de buscar para la actividad en concreto
                                               y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
    6.0        09/04/2009  JTS              6. BUG9748 - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
    7.0        28/04/2009  APD              7. 0009720: APR - número de poliza incorrecto en NP
    8.0        12/05/2009  DRA              8. 0009598: CEM - Refresco de los capitales de garantía
    9.0        02/06/2009  ICV              9. 0008947: CRE046 - Gestión de cobertura Enfermedad Grave en siniestros
    10.0       19/08/2009  JRH              10.0010898: CRE - Mantener Capitales migrados en productos de salud al realizar suplemento
    11.0       07/09/2009  DRA              11.0010494: IAX - Trapàs de preguntes a nivell de garantia
    12.0       16/09/2009  XPL              12.0011091: APR - error en la pantalla de simulacion
    13.0       18/09/2009  DRA              13.0010947: APR - Error en el alta de pólizas si cambias la fecha de efecto
    14.0       22/09/2009  DRA              14.0011183: CRE - Suplemento de alta de asegurado ya existente
    15.0       14/10/2009  DRA              15.0011458: CRE - Error a l'acceptar propostes de suplement retingudes
    16.0       12/05/2009  DRA              16.0009496: IAX - Contractació: Gestió de preguntes de garantia + control selecció mínim 1 garantia
    17.0       02/11/2009  APD              17.0011301: CRE080 - FOREIGNS DE PRESTAMOSEG
    18.0       09/11/2009  APD              18.Bug 11595: CEM - Siniestros. Adaptación al nuevo módulo de siniestros
                                                              -- Define idioma actual de mensajes
    19.0       20/01/2010  JMF              19.Bug 0012802: CEM - Acceso a la vista PERSONAS
    20.0       27/01/2010  RSC              20. 0011735: APR - suplemento de modificación de capital /prima
    21.0       24/02/2010  DRA              21. 0013352: CEM003 - SUPLEMENTS: Parametritzar canvi de forma de pagament pels productes de risc
    22.0       29/03/2010  DRA              22. 0013945: CRE 80- Saldo deutors III
    23.0       26/04/2010  DRA              23. 0014279: CRE 80- Saldo deutors IV
    24.0       27/05/2010  DRA              24. 0014652: CEM - modificación coberturas ESCUT
    25.0       07/06/2010  DRA              25. 0011288: CRE - Modificación de propuestas retenidas
    26.0       30/07/2010  XPL              26. 14429: AGA005 - Primes manuals pels productes de Llar
    27.0       23/08/2010  DRA              27. 0015617: AGA103 - migración de pólizas - Numeración de polizas
    28.0       19/10/2010  DRA              28. 0016372: CRE800 - Suplements
    29.0       15/12/2010  JMP              29. 0017008: GRC - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nÂº de póliza
    30.0       11/01/2011  APD              30. 0017221: APR - Se crea la funcion f_validar_baja_gar_col
    31.0       24/01/2011  JMP              31.0017341: APR703 - Suplemento de preguntas - FlexiLife
    32.0       05/04/2011  ICV              32. 0017939: CX803 - Rehabilitación pago periódico
    33.0       04/05/2011  ICV              33. 0018350: LCOL003 - Garantías dependientes múltiples 'AND'
    34.0       02/05/2011  SRA              34. 0018345: LCOL003 - Validación de garantías dependientes de respuestas u otros factores
    35.0       30/05/2011  ETM              35. 0018631: ENSA102- Alta del certificado 0 en Contribución definida
    36.0       29/06/2011  APD              36. 0018848: LCOL003 - Vigencia fecha de tarifa
    37.0       30/08/2011  JMF              37. 0019332: LCOL001 -numeración de pólizas y de solicitudes
    38.0       19/10/2011  RSC              38. 0019412: LCOL_T004: Completar parametrización de los productos de Vida Individual
    39.0       11/11/2011  ETM              39 .0019338:NOTA:97501--- LCOL_T004 - Análisis Parametrización Vida Individual
    40.0       21/11/2011  JMC              40. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
    41.0       26/11/2011  DRA              41. 0020234: AGM - Error en la pantalla AXISCTR005 (Multiriesgo innominado)
    42.0       10/12/2011  RSC              42. 0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2Âª parte)
    43.0       04/01/2012  RSC              43. 0020671: LCOL_T001-LCOL - UAT - TEC: Contratación
    45.0       13/01/2012  RSC              45. 0019715: LCOL: Migración de productos de Vida Individual
    46.0       10/02/2012  DRA              46. 0020498: LCOL_T001-LCOL - UAT - TEC - Beneficiaris de la p?lissa
    47.0       23/02/2012  DRA              47. 0021459/108099 - CRE800 - Suplement PPJ Garantit
    48.0       24/02/2012  APD              48. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
    49.0       23/03/2012  RSC              49. 0021780: LCOL_T001 - Ajuste parametrización plantillas del producto Seguro Saldado y Seguro Prorrogado
    50.0       23/03/2012  FAL              50. 0021664: 0021664: GIP103-Incidencias Post-Arranque
    51.0       27/03/2012  MDS              51. 0021707: MDP_T001- TEC : Capital por defecto: Fijo o el de otra garant?a.
    52.0       27/03/2012  APD              52. 0021786: MDP_T001-Modificaciones pk_nueva_produccion para corregir inidencias en dependencias
    53.0       27/04/2012  APD              53. 0021706: MDP_T001- TEC : Capital máximo calculado o dependiente de otra
    54.0       18/05/2012  APD              54. 0021786: MDP_T001-Modificaciones pk_nueva_produccion para corregir inidencias en dependencias
    55.0       04/09/2012  APD              55. 0022964: MDP - MHG 2008 - Revisión Incidencias
    56.0       14/09/2012  APD              56. 0022964: MDP - MHG 2008 - Revisión Incidencias
    57.0       21/09/2012  FAL              57. 0023681: CRE800 - Contractació CVFinanÃ§ament
    58.0       15/11/2012  LECG             58. 0024714: LCOL_T001-QT 5382: No existen movimientos de anulaci?n ni la causa siniestro/motivo para polizas prorrogadas/saldadas
    59.0       14/12/2012  DRA              59. 0025037: CRE800: PIAM individual - assegurats amb 65 anys i capital mort incorrecte
    60.0       20/12/2012  MDS              60. 0024717: (POSPG600)-Parametrizacion-Tecnico-Descripcion en listas Tipos Beneficiarios RV - Cambiar descripcion en listas Tipos Beneficiar
    61.0       07/02/2013  FPG              61. 0025584: uso del parámetro de producto VALIDA_EDAD_ASEG_PRO
    62.0       28/02/2013  MMS              62. 0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto
    63.0       09/04/2013  FAL              63. 0026550: GIP802 - Flotas. 3 incidencias (GIP-027, GIP-028, GIP-029)
    64.0       24/05/2013  ETM              64. 0024715: (POSPG600)-Revisar anulaciones y Rehabilitaciones.Parametrizacion-Tecnico-Parametrizar corto plazo y rescates anualidad Cumplida
    65.0       06/06/2013  MMS              65. 0025584: POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto - add NEDAMAR
    66.0       06/06/2013  MMS              66. 0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)
    67.0       28/01/2014  APD              67. 0029582: LCOL_T010-Revision incidencias qtracker (2014/01)
    68.0       14/04/2014  dlF              68. 0027744: AGM900 - Producto de Explotaciones 2014
    69.0       25/06/2014  FBL              69. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
    70.0       03/09/2014  FAL              70. 0031992: LCOL_T010-Revisión incidencias qtracker (2014/07); QT: 13831
    71.0       07/10/2014  JMF              71. BUG 32015 Control error y mostrar sentencia que causa el problema
	  72.0       17/03/2016  ACL              72. BUG 41043 POSES100-POS-TEC ERROR AL TARIFAR EN PRODUCTO LARGO PLAZO INV
    73.0       23/04/2019  RABQ             73. IAXIS-3408 Ajuste Mensajes al momneto de tarifar.
    74.0       16/05/2019  ECP              74. IAXIS-3631 Cambio de Estado cuando las pólizas están vencidas (proceso nocturno)
	75.0       22/05/2019  CES              75. Ajuste error en cambio de actividad para suplementos.
	76.0       05/08/2019  CJMR             76. IAXIS-4200: Validación preguntas RC
   ******************************************************************************/
   global_usu_idioma idiomas.cidioma%TYPE;   -- Define idioma actual de mensajes
   global_modo    VARCHAR2(8);
   -- Bug 21786 - APD - 28/03/2012 - se debe actualizar a FALSE la variable
   isaltacol      BOOLEAN := FALSE;

   -- fin Bug 21786 - APD - 28/03/2012
   ----
   PROCEDURE p_define_modo(p_in_modo IN VARCHAR2) IS
   BEGIN
      -- Si es un valor no admitido, deja el defecto
      SELECT DECODE(NVL(p_in_modo, 'EST'), 'EST', 'EST', 'SOL', 'SOL', 'EST')
        INTO global_modo
        FROM DUAL;

      global_usu_idioma := f_usu_idioma;
   END p_define_modo;

   -- BUG9216:DRA:23-02-2009:Creo la funcion que devuelve la descripción de una garantia si es posible
   /*************************************************************************
       FUNCTION aux_f_desgarantia
       Devuelve la descripción de una garantia si es posible
       param in p_in_cgarant  : código de la garantia
       return                 : VARCHAR2 (descripción de la garantia)
   *************************************************************************/
   FUNCTION aux_f_desgarantia(p_in_cgarant IN garangen.cgarant%TYPE)
      RETURN VARCHAR2 IS
      w_desc         garangen.tgarant%TYPE;
      w_error        NUMBER;
   BEGIN
      IF p_in_cgarant IS NOT NULL THEN
         w_error := f_desgarantia(p_in_cgarant, global_usu_idioma, w_desc);
      END IF;

      RETURN w_desc;
   EXCEPTION
      WHEN OTHERS THEN
         w_desc := p_in_cgarant;
         --- Es solo informativo, no provocará error ni guardará mensaje
         RETURN w_desc;
   END aux_f_desgarantia;

   FUNCTION f_ins_estseguros(
      psproduc IN NUMBER,
      pcempres IN NUMBER DEFAULT 1,
      psseguro OUT NUMBER,
      pcidioma IN NUMBER DEFAULT 2,
      pcagente IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /*Función que realiza el primer insert en estseguros, retorna el sseguro de
        las tablas EST,informamos el sseguro real y copiamos el sseguro en campo
        npoliza
        NOTA: función solo valida para los productos que no son colectivos,
        si son colectivos sólo es valido para el primer certificado.
      19-7-2004. Ya es válido para colectivos individualizados.
       */
      v_sestudi      NUMBER;
      v_sseguro      NUMBER;
      prod           productos%ROWTYPE;
      v_ncertif      NUMBER;
      v_nrenova      NUMBER;
      v_fecha        DATE;
      v_cagente      NUMBER;
      v_cobban       NUMBER;
      ttexto         VARCHAR2(1000);
      v_npoliza      NUMBER;
      v_nsolicit     NUMBER;
   BEGIN
      v_cobban := 1;

      SELECT sestudi.NEXTVAL
        INTO v_sestudi
        FROM DUAL;

      SELECT sseguro.NEXTVAL
        INTO v_sseguro
        FROM DUAL;

      SELECT *
        INTO prod
        FROM productos
       WHERE sproduc = psproduc;

      IF pnpoliza IS NOT NULL THEN
         v_npoliza := pnpoliza;
      ELSE
         -- ini BUG 0019332 - 30/08/2011 - JMF
         --         v_npoliza := v_sseguro;
         DECLARE
            v_numaddpoliza NUMBER;
         BEGIN
            v_numaddpoliza := pac_parametros.f_parempresa_n(pcempres, 'NUMADDPOLIZA');
            v_npoliza := v_sseguro + NVL(v_numaddpoliza, 0);
         END;
      -- fin BUG 0019332 - 30/08/2011 - JMF
      END IF;

      -- Bug 8745 - 01/04/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
      -- 'ADMITE_CERTIFICADOS'
      IF prod.csubpro = 3
         OR NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN   -- producto colectivo individualizado
         IF pnpoliza IS NULL THEN
            RETURN 104293;   -- falta el número de póliza
         END IF;

         IF NVL(f_parproductos_v(psproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 THEN
            SELECT ssolicit_certif.NEXTVAL
              INTO v_ncertif
              FROM DUAL;
         ELSE
             -- aunque ahora busquemos el ncertif, en realidad puede no ser el definitivo,
            -- hay que volver a buscarlo cuando se grabe la póliza en SEGUROS
            BEGIN
               SELECT NVL(MAX(ncertif), 0) + 1
                 INTO v_ncertif
                 FROM seguros
                WHERE npoliza = pnpoliza
                  AND csituac <> 4;
            -- que no sea propuesta de alta
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 101919;   -- ERROR AL LEER DATOS DE LA TABLA SEGUROS
            END;
         END IF;
      ELSE
         -- Si el npoliza se asigan en la emisión, se graba el número de solicitud
         IF NVL(f_parproductos_v(psproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 THEN
            -- BUG 0019332 - 30/08/2011 - JMF
            v_nsolicit := pac_propio.f_numero_solici(pcempres, prod.cramo);
         END IF;

         v_ncertif := 0;
      END IF;

      IF prod.ctipefe = 2 THEN
         IF TO_CHAR(f_sysdate, 'dd') = 1 THEN
            v_fecha := f_sysdate;
         ELSE
            v_fecha := ADD_MONTHS(f_sysdate, 1);
         END IF;

         v_nrenova := TO_CHAR(v_fecha, 'mm') || '01';
      ELSIF prod.ctipefe = 3 THEN
         v_nrenova := TO_CHAR(f_sysdate, 'mm') || '01';
      ELSIF prod.ctipefe = 1 THEN
         v_nrenova := prod.nrenova;
      ELSE
         v_nrenova := TO_CHAR(f_sysdate, 'mmdd');
      END IF;

      v_cagente := pcagente;   --f_oficina_mv;

      IF v_cagente IS NULL THEN
         RETURN 102445;   --oficina inexistente
      END IF;

      BEGIN
         INSERT INTO estseguros
                     (sseguro, ssegpol, cramo, cmodali, ccolect,
                      ctipseg, nsuplem, cempres, cagrpro, npoliza, cobjase,
                      ctarman, fefecto, crecman, csituac, nanuali, ncertif,
                      sproduc, cactivi, cforpag, cduraci, casegur, cagente, creafac,
                      ctipreb, ctiprea, creccob, ctipcom, ctipcol, nrenova, ctipcoa,
                      nfracci, ctipest, crevali, irevali,
                      prevali, crecfra, creteni, ccobban, nsolici)
              VALUES (v_sestudi, v_sseguro, prod.cramo, prod.cmodali, prod.ccolect,
                      prod.ctipseg, 0, pcempres, prod.cagrpro, v_npoliza, prod.cobjase,
                      prod.ctarman, TO_CHAR(f_sysdate, 'dd/mm/yyyy'), 0, 4, 1, v_ncertif,
                      prod.sproduc, 0, prod.cpagdef, prod.cduraci, 0, v_cagente, 0,
                      prod.ctipreb, 0, prod.creccob, 0, 1, v_nrenova, 0,
                      DECODE(prod.cpagdef, 1, 0, 1), 0, prod.crevali, prod.irevali,
                      prod.prevali, prod.crecfra, prod.creteni, v_cobban, v_nsolicit);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104566;   --error al modificar estseguros.
      END;

      --si todo ha ido bien, informamos la variable de salida
      psseguro := v_sestudi;

      -- Si es una poliza de ahorro grabamos en ESTSEGUROS_AHO
       --IF f_prod_ahorro(psproduc) = 1 THEN -- es un producto de ahorro
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_AHO'), 0) = 1 THEN   -- es un producto de ahorro
         --  INSERTAMOS EN LA TABLA ESTSEGUROS_AHO
         BEGIN
            INSERT INTO estseguros_aho
                        (sseguro, pinttec, pintpac, fsusapo, ndurper)
                 VALUES (psseguro, NULL, NULL, NULL, NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_ins_estseguros', NULL,
                           'error al insertar en estseguros_aho.',
                           SQLERRM || ' ( sseguro =' || psseguro || '  )');
               RETURN 140256;
         END;
      END IF;

      -- si es una poliza producto indexado grabamos en ESTSEGUROS_ULK
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_INDEXADO'), 0) = 1 THEN   -- es un producto de ahorro
         --  INSERTAMOS EN LA TABLA ESTSEGUROS_AHO
         BEGIN
            INSERT INTO estseguros_ulk
                        (sseguro, psalmin, isalcue, cseghos, cmodinv, cgasges, cgasred)
                 VALUES (psseguro, NULL, NULL, NULL, NULL, NULL, NULL);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_ins_estseguros', NULL,
                           'error al insertar en estseguros_ulk.',
                           SQLERRM || ' ( sseguro =' || psseguro || '  )');
               RETURN 140256;
         END;
      END IF;

       --JRH IMP Esto no estaba en el source safe, habrá que ponerlo
      -- si es una poliza producto de rentas grabamos en ESTSEGUROS_REN
      IF NVL(f_parproductos_v(psproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN   -- es un producto de ahorro
         --  INSERTAMOS EN LA TABLA ESTSEGUROS_AHO
         BEGIN   --JRH IMP En rentas aprovechamos la tabla de ahorro para guardar las duraciones y aprovechar los procesos que tiran de ella
            INSERT INTO estseguros_aho
                        (sseguro, pinttec, pintpac, fsusapo, ndurper)
                 VALUES (psseguro, NULL, NULL, NULL, NULL);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_ins_estseguros', NULL,
                           'error al insertar en estseguros_aho.',
                           SQLERRM || ' ( sseguro =' || psseguro || '  )');
               RETURN 140256;
         END;

         BEGIN
            INSERT INTO estseguros_ren
                        (sseguro, f1paren,
                         fuparen, cforpag, ibruren)   --JRH IMP
                 VALUES (psseguro, TO_DATE('01/01/2008', 'DD/MM/YYYY'),
                         TO_DATE('01/01/2008', 'DD/MM/YYYY'), 0, 0);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_ins_estseguros', NULL,
                           'error al insertar en estseguros_ren.',
                           SQLERRM || ' ( sseguro =' || psseguro || '  )');
               RETURN 140256;
         END;
      END IF;

      -- insertamos en estdetmovseguro que es una alta de polizas.
      ttexto := f_axis_literales(151347, pcidioma);

      BEGIN
         INSERT INTO estdetmovseguro
                     (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora, tvalord, cpregun)
              VALUES (psseguro, 1, 100, 0, 0, NULL, ttexto, 0);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104566;   --error al modificar estseguros.
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 140999;   -- Error no controlat
   END f_ins_estseguros;

   FUNCTION f_ins_esttomador(psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS
      /*****************************************************************************
       Función que retorna el nordtom para un seguro y persona
      ******************************************************************************/
      cont           NUMBER;
   BEGIN
      --primero validamos que el tomador no exista ya en la poliza.
      SELECT COUNT(1)
        INTO cont
        FROM esttomadores
       WHERE sseguro = psseguro
         AND sperson = psperson;

      IF cont >= 1 THEN
         RETURN 151086;   --este tomador ya existe.
      END IF;

      SELECT MAX(nordtom)
        INTO cont
        FROM esttomadores
       WHERE sseguro = psseguro;

      RETURN NVL(cont, 0) + 1;
   END f_ins_esttomador;

   FUNCTION f_valida_tomador(psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS
      vcdomici       esttomadores.cdomici%TYPE;
      -- Bug 0012802 - 20/01/2010 - JMF
      vcestado       per_personas.cestper%TYPE;
      v_fefecto      DATE;
      -- Bug 0012802 - 20/01/2010 - JMF
      v_cpertip      per_personas.ctipper%TYPE;
      v_fnacimi      DATE;
      num_err        NUMBER;
      edad           NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      SELECT cdomici, fefecto, sproduc
        INTO vcdomici, v_fefecto, v_sproduc
        FROM esttomadores t, estseguros s
       WHERE t.sseguro = psseguro
         AND t.sseguro = s.sseguro
         AND t.sperson = psperson;

      IF vcdomici IS NULL THEN
         RETURN 151094;   --El domicili de prenedor és obligatori
      END IF;

      -- Bug 0012802 - 20/01/2010 - JMF
      SELECT cestper, ctipper, fnacimi
        INTO vcestado, v_cpertip, v_fnacimi
        FROM estper_personas
       WHERE sperson = psperson;

      IF NVL(vcestado, 0) = 2 THEN
         RETURN 101253;   --Persona fallecida
      END IF;

      IF v_cpertip = 1 THEN   -- PERSONA FÃ¿SICA
         num_err := f_difdata(v_fnacimi, v_fefecto, 1, 1, edad);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF edad < 18 THEN
            RETURN 109631;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 101903;   --AsseguranÃ§a no trobada
   END f_valida_tomador;

   FUNCTION f_ins_estriesgo_tomador(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pnmovima IN NUMBER,
      pfefecto IN DATE,
      pcdomici IN NUMBER,
      pfnacimi IN DATE,
      pcsexper IN NUMBER)
      RETURN NUMBER IS
      /******************************************************************************
      Función que inserta un asegurado/riesgo con los datos que nos pasan por
      parametros, siempre que cumpla las condiciones
       1.- no existan ya asegurados, para esa póliza
      ******************************************************************************/
      vnriesgo       NUMBER;
   BEGIN
      vnriesgo := 1;

      BEGIN
         INSERT INTO estriesgos
                     (nriesgo, sseguro, nmovima, fefecto, sperson, cdomici)
              VALUES (vnriesgo, psseguro, pnmovima, pfefecto, psperson, pcdomici);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE estriesgos
               SET fefecto = pfefecto,
                   sperson = psperson,
                   cdomici = pcdomici,
                   nmovima = pnmovima
             WHERE sseguro = psseguro
               AND nriesgo = vnriesgo;
      END;

      BEGIN
         DELETE      estassegurats
               WHERE sseguro = psseguro
                 AND norden = vnriesgo;

         INSERT INTO estassegurats
                     (sseguro, sperson, norden, cdomici, ffecini, nriesgo)   -- BUG11183:DRA:08/10/2009
              VALUES (psseguro, psperson, vnriesgo, pcdomici, pfefecto, vnriesgo);   -- BUG11183:DRA:08/10/2009
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE estassegurats
               SET cdomici = pcdomici,
                   sperson = psperson,
                   ffecini = pfefecto,
                   nriesgo = vnriesgo   -- BUG11183:DRA:08/10/2009
             WHERE sseguro = psseguro
               AND norden = vnriesgo;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 151132;
   END f_ins_estriesgo_tomador;

   FUNCTION f_valida_datosgestion(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      tipo OUT NUMBER,
      campo OUT VARCHAR2,
      modo IN VARCHAR2)
      RETURN NUMBER IS
      /*****************************************************************************
      Función que valida lNos datos de gestión.
      *****************************************************************************/
      vcidioma       estseguros.cidioma%TYPE;
      vfefecto       DATE;
      vfvencim       DATE;
      num_err        NUMBER;
      vdias_a        NUMBER;
      vdias_d        NUMBER;
      vcbancar       seguros.cbancar%TYPE;
      vcduraci       estseguros.cduraci%TYPE;
      vctipcob       estseguros.ctipcob%TYPE;
      vmeses_a       NUMBER;
      vmeses_d       NUMBER;

      CURSOR riesgos IS
         -- Bug 0012802 - 20/01/2010 - JMF
         SELECT fnacimi
           FROM estper_personas p, estriesgos e
          WHERE p.sperson = e.sperson
            AND e.sseguro = psseguro;
   BEGIN
      SELECT cidioma, fvencim, fefecto, cbancar, cduraci, ctipcob
        INTO vcidioma, vfvencim, vfefecto, vcbancar, vcduraci, vctipcob
        FROM estseguros
       WHERE sseguro = psseguro;

      IF modo = 'ALTA_POLIZA' THEN
         num_err := f_parproductos(psproduc, 'DIASATRAS', vdias_a);
         num_err := f_parproductos(psproduc, 'DIASDESPU', vdias_d);
         -- 34866/206242
         vmeses_a := NVL(f_parproductos_v(psproduc, 'MESESATRAS'), 0);
         vmeses_d := NVL(f_parproductos_v(psproduc, 'MESESDESPU'), 0);

         -- Calcular v_dias:
         -- Si la fecha de efecto esta en diferente aÃ±o al actual de la emisión de la
         -- la propuesta, solo se permitirá retroactividad hasta el principio del aÃ±o:
         --
         IF vmeses_a != 0 THEN
            IF (ADD_MONTHS(vfefecto, vmeses_a) >= TRUNC(f_sysdate)) THEN
               IF TO_NUMBER(TO_CHAR(vfefecto, 'YYYY')) <>
                                                         TO_NUMBER(TO_CHAR(f_sysdate, 'YYYY')) THEN
                  vmeses_a := NULL;
                  vdias_a := TRUNC(f_sysdate
                                   - TO_DATE('01/01/' || TO_CHAR(f_sysdate, 'YYYY'),
                                             'dd/mm/yyyy'));
               ELSE
                  vmeses_a := NULL;
                  vdias_a := TRUNC(f_sysdate - vfefecto);
               END IF;
            ELSE
               IF ADD_MONTHS(vfefecto, vmeses_a) < TRUNC(f_sysdate) THEN
                  vmeses_a := NULL;
                  vdias_a := f_sysdate - ADD_MONTHS(f_sysdate, -1 * vmeses_a);
               END IF;
            END IF;
         END IF;

         IF vmeses_d != 0 THEN
            vdias_d := TRUNC(ADD_MONTHS(f_sysdate, vmeses_d) - f_sysdate);
         END IF;

         IF vdias_d = -1 THEN   --primer dia del mes siguiente
            vdias_d := LAST_DAY(f_sysdate) + 1 - f_sysdate;
         END IF;

         IF vfefecto IS NULL THEN
            tipo := 1;
            campo := 'FEFECTO';
            RETURN 104532;
         ELSIF vfefecto + NVL(vdias_a, 0) < TRUNC(f_sysdate) THEN
            tipo := 2;
            campo := 'FEFECTO';
            RETURN 109909;
         ELSIF vfefecto > TRUNC(f_sysdate) + NVL(vdias_d, 0) THEN
            tipo := 2;
            campo := 'FEFECTO';
            RETURN 101490;
         END IF;
      END IF;

      IF vfvencim IS NOT NULL THEN
         IF vfvencim <= vfefecto THEN
            tipo := 2;
            campo := 'FVENCIM';
            RETURN 100022;
         END IF;
      ELSE
         -- Bug 23117 - RSC - 30/07/2012 - LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN ANO (aNadimos 6)
         IF vcduraci NOT IN(0, 4, 6) THEN
            tipo := 2;
            campo := 'FVENCIM';
            RETURN 151288;
         END IF;
      END IF;

      IF vcidioma IS NULL THEN
         tipo := 1;
         campo := 'CIDIOMA';
         RETURN 102242;
      END IF;

      IF vcbancar IS NULL
         AND vctipcob = 2 THEN
         tipo := 1;
         campo := NULL;
         RETURN 151103;
      END IF;

      FOR c IN riesgos LOOP
         num_err := f_validar_duracion(psproduc, psseguro, c.fnacimi, vfefecto, vfvencim);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN 0;
   END f_valida_datosgestion;

   FUNCTION f_ins_estriesgo(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pmodo IN NUMBER DEFAULT 1,
      pcdomici IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      /*****************************************************************************
       Función que retorna el nordtom para un seguro y persona
      ******************************************************************************/
      cont           NUMBER;
   BEGIN
      --primero validamos que el risc no exista ya en la poliza.
      SELECT COUNT(1)
        INTO cont
        FROM estriesgos
       WHERE sseguro = psseguro
         AND sperson = psperson;

      IF cont >= 1 THEN
         RETURN 120110;   --El risc ja existeix
      END IF;

      SELECT MAX(nriesgo)
        INTO cont
        FROM estriesgos
       WHERE sseguro = psseguro;

      IF pmodo = 2 THEN
         INSERT INTO estriesgos
                     (nriesgo, sseguro, nmovima, fefecto, sperson, cdomici)
              VALUES (NVL(cont, 0) + 1, psseguro, 1, pfefecto, psperson, pcdomici);
      END IF;

      RETURN NVL(cont, 0) + 1;
   END f_ins_estriesgo;

   FUNCTION f_ins_estassegurat(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pmodo IN NUMBER DEFAULT 1,
      pcdomici IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      /*****************************************************************************
       Función que retorna el norden para un seguro y persona
      ******************************************************************************/
      cont           NUMBER;
   BEGIN
      --primero validamos que el risc no exista ya en la poliza.
      SELECT COUNT(1)
        INTO cont
        FROM estassegurats
       WHERE sseguro = psseguro
         AND sperson = psperson
         AND ffecfin IS NULL;   -- BUG11183:DRA:22/09/2009

      IF cont >= 1 THEN
         RETURN 120110;   --El risc ja existeix
      END IF;

      SELECT MAX(norden)
        INTO cont
        FROM estassegurats
       WHERE sseguro = psseguro;

      IF pmodo = 2 THEN
         INSERT INTO estassegurats
                     (sseguro, sperson, norden, cdomici, ffecini, nriesgo)   -- BUG11183:DRA:08/10/2009
              VALUES (psseguro, psperson, NVL(cont, 0) + 1, pcdomici, pfefecto, NVL(cont, 0)
                                                                                + 1);   -- BUG11183:DRA:08/10/2009
      END IF;

      RETURN NVL(cont, 0) + 1;
   END f_ins_estassegurat;

   FUNCTION f_valida_estriesgo(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      psproduc IN NUMBER,
      pcdomici IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vcdomici       estriesgos.cdomici%TYPE;
      -- Bug 0012802 - 20/01/2010 - JMF
      vcsexper       per_personas.csexper%TYPE;
      vfnacimi       DATE;
      -- Bug 0012802 - 20/01/2010 - JMF
      vcestado       per_personas.cestper%TYPE;
      vctipper       per_personas.ctipper%TYPE;
      vnedamic       productos.nedamic%TYPE;
      vciedmic       productos.ciedmic%TYPE;
      vnedamac       productos.nedamac%TYPE;
      vciedmac       productos.ciedmac%TYPE;
      vnsedmac       productos.nsedmac%TYPE;
      vcisemac       productos.cisemac%TYPE;
      vfefecto       DATE;
      vcvalpar       NUMBER;
      num_err        NUMBER;
      vssegpol       estseguros.ssegpol%TYPE;
      vcobjase       productos.cobjase%TYPE;
      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0
      vnpoliza       estseguros.npoliza%TYPE;
      v_existe       NUMBER;
      v_escertif0    NUMBER;
      vsseguro       estseguros.ssegpol%TYPE;
-- JLB - 26301 - I - RSA - Validación póliza partner
      vcpolcia       estseguros.cpolcia%TYPE;
      vcagente       estseguros.cagente%TYPE;
      vcempres       estseguros.cempres%TYPE;
      vspereal       estpersonas.spereal%TYPE;

-- JLB - 26301 - F - RSA - Validación póliza partner

      -- Fin Bug 22839
      CURSOR riesgos IS
         SELECT sperson, nriesgo
           FROM estriesgos
          WHERE sseguro = psseguro;

      CURSOR asegurados IS
         SELECT sperson, nriesgo, fefecto, cdomici, fanulac
           FROM estriesgos e
          WHERE e.sseguro = psseguro
            AND(e.sperson, e.nriesgo) NOT IN(SELECT s.sperson, s.norden
                                               FROM estassegurats s
                                              WHERE s.sseguro = psseguro);

      CURSOR asegurados2 IS
         SELECT sperson, nriesgo, fefecto, cdomici, fanulac
           FROM estriesgos e
          WHERE e.sseguro = psseguro
            AND(e.nriesgo) NOT IN(SELECT s.norden
                                    FROM estassegurats s
                                   WHERE s.sseguro = psseguro);
   BEGIN
      SELECT cobjase
        INTO vcobjase
        FROM productos
       WHERE sproduc = psproduc;

      --
      -- Asteriscado el if  ALTACERO_DESCRIPCION' Pq si no es una descripción y es colectivo y alta es del certif 0 no tiene que validar Edades del Riesgo
      --
      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0
--   IF NVL(pac_parametros.f_parproducto_n(psproduc, 'ALTACERO_DESCRIPCION'), 0) = 1 THEN
      BEGIN
         SELECT npoliza, ssegpol, fefecto, ssegpol
-- JLB - 26301 - I - RSA - Validación póliza partner
         ,      cpolcia, cagente, cempres
           INTO vnpoliza, vsseguro, vfefecto, vssegpol
-- JLB - 26301 -- RSA - Validación póliza partner
         ,      vcpolcia, vcagente, vcempres
           FROM estseguros
          WHERE sseguro = psseguro;

         isaltacol := FALSE;

         IF NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, vsseguro);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe <= 0 THEN
                  isaltacol := TRUE;
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            isaltacol := FALSE;
      END;

      IF isaltacol THEN
         vcobjase := 3;
      END IF;

--    END IF;

      -- Fin bug 22839
      IF vcobjase = 1
         AND psseguro IS NOT NULL THEN
              --Si el objeto asegurado es una persona.
         --     SELECT cdomici
           --     INTO vcdomici
           --     FROM estriesgos
            --   WHERE sseguro = psseguro
            --     AND sperson = psperson;

         --   IF vcdomici IS NULL THEN
         --      RETURN 140083;   --El domicili obligatori
         --   END IF;
         BEGIN
            -- Bug 0012802 - 20/01/2010 - JMF
            SELECT fnacimi, csexper, cestper, ctipper, spereal
              INTO vfnacimi, vcsexper, vcestado, vctipper, vspereal
              FROM estper_personas
             WHERE sperson = psperson;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 109617;   --Persona no trobada
         END;

         IF vctipper = 2 THEN
            RETURN 152093;
         END IF;

         IF vfnacimi IS NULL
            OR vcsexper IS NULL THEN
            RETURN 151133;   --Persona no válida com a risc.
         END IF;

         IF NVL(vcestado, 0) = 2
            AND NVL(pac_iaxpar_productos.f_get_parproducto('CONTRATA_MUERTO', psproduc), 0) = 0 THEN
            RETURN 101253;   --Persona fallecida
         END IF;

             --seleccionamos la fecha de efecto de la póliza para validar la edad de los asegurados
         --    SELECT fefecto, ssegpol
         --      INTO vfefecto, vssegpol
         --      FROM estseguros
         --     WHERE sseguro = psseguro;

         --Seleccionamos la edad máxima y mínima por producto
         SELECT nedamic, nedamac, ciedmic, ciedmac, nsedmac, cisemac
           INTO vnedamic, vnedamac, vciedmic, vciedmac, vnsedmac, vcisemac
           FROM productos
          WHERE sproduc = psproduc;

         num_err := f_control_edat(psperson, vfefecto, NVL(vnedamic, 0), NVL(vciedmic, 0),
                                   NVL(vnedamac, 999), NVL(vciedmac, 0), NVL(vnsedmac, 999),
                                   NVL(vcisemac, 0), NULL, 1);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := pac_propio.f_valida_estriesgo_producto(psseguro, psproduc, psperson);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- una póliza del mismo producto, por persona.
         num_err := f_parproductos(psproduc, 'POLIZA_UNICA', vcvalpar);

         IF NVL(vcvalpar, 0) = 1 THEN
            SELECT COUNT(1)
              INTO num_err
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = vspereal
               AND r.sseguro <> vssegpol
               AND s.sproduc = psproduc
               AND r.fanulac IS NULL   --que el riesgo no este anulado
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar también que no estén vencidas
                           -- AND s.csituac <> 2   -- que no estén anuladas
               AND s.csituac NOT IN(2, 3)   -- que no estén anuladas ni vencidas
               -- FI BUG 11330  - 15/10/2009 â€“ FAL
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > vfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)));

               -- FI BUG 26070/0138253
            -- y no sean prop.alta anuladas o rechazadas.
            IF num_err > 0 THEN
               RETURN 151240;
            END IF;
         -- BUG 26070/0138253 - FAL - 16/02/2013
         ELSIF NVL(vcvalpar, 0) = 2 THEN   --RAMO
            SELECT COUNT(1)
              INTO num_err
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = vspereal
               AND r.sseguro <> vssegpol
               AND s.cramo IN(SELECT cramo
                                FROM productos
                               WHERE sproduc = psproduc)
               AND r.fanulac IS NULL
               AND s.csituac NOT IN(2, 3)
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 11330 - 15/10/2009 - FAL - Filtrar no se cuenten pólizas con vencimiento programado a fecha anterior al efecto de la nueva póliza
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > vfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)));

            IF num_err > 0 THEN
               RETURN 9001931;
            END IF;
         ELSIF NVL(vcvalpar, 0) = 3 THEN   --AGRUPACION
            SELECT COUNT(1)
              INTO num_err
              FROM riesgos r, seguros s, productos p
             WHERE r.sseguro = s.sseguro
               AND r.sperson = vspereal
               AND r.sseguro <> vssegpol
               AND s.cagrpro IN(SELECT cagrpro
                                  FROM productos
                                 WHERE sproduc = psproduc)
               AND r.fanulac IS NULL
               AND s.csituac NOT IN(2, 3)
               AND NOT(s.csituac = 4
                       AND s.creteni IN(3, 4))
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > vfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)));

            IF num_err > 0 THEN
               RETURN 9001932;
            END IF;
         ELSIF NVL(vcvalpar, 0) = 4 THEN   --COLECTIVO
            SELECT COUNT(1)
              INTO num_err
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = vspereal
               AND r.sseguro <> vssegpol
               AND s.npoliza = vnpoliza
               AND r.fanulac IS NULL
               AND s.csituac NOT IN(2, 3)
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND s.fvencim > vfefecto
                      AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 1
                          OR pac_anulacion.f_esta_anulada_vto(s.sseguro) = 1)));

            IF num_err > 0 THEN
               RETURN 9904994;
            END IF;
         -- FI BUG 26070/0138253
         END IF;

         -- POLIZA ÚNICA POR AGENTE Y CPOLCIA
         -- JLB - 26301 -- RSA - Validación póliza partner
         vcvalpar := NVL(pac_parametros.f_parempresa_n(vcempres, 'POLIZA_UNICA_PARTNER'), 0);

         IF vcvalpar = 1 THEN
            SELECT COUNT(1)
              INTO num_err
              FROM seguros s
             WHERE s.cagente = vcagente
               AND s.cpolcia = vcpolcia
               AND s.sseguro <> vssegpol
               AND s.csituac <> 2   --que no estén anuladas
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4))
               -- BUG 26070/0138253 - FAL - 16/02/2013
               --AND((s.fvencim IS NULL)  AND(pac_anulacion.f_esta_prog_anulproxcar(s.sseguro) = 0  AND pac_anulacion.f_esta_anulada_vto(s.sseguro) = 0))
               AND((s.fvencim IS NULL)
                   OR(s.fvencim IS NOT NULL
                      AND vfefecto BETWEEN s.fefecto AND s.fvencim));

            IF num_err > 0 THEN
               RETURN 9905553;
            END IF;
         END IF;

         -- JLB - 26301 - F - RSA - Validación póliza partner
         IF NVL(f_parproductos_v(psproduc, 'ALTA_CON_POL_PDTE'), 0) = 0 THEN
            --Solo una póliza con creteni diferente de 0
            SELECT COUNT(1)
              INTO num_err
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = vspereal
               AND r.sseguro <> vssegpol
               AND s.sproduc = psproduc
               AND s.creteni <> 0
               AND s.csituac <> 2
               AND NOT(s.csituac = 4
                       AND creteni IN(3, 4));

            -- y no sean prop.alta anuladas o rechazadas.;
            IF num_err > 0 THEN
               RETURN 151241;
            END IF;
         -- Bug 0020671 - RSC - 04/01/2012 - LCOL_T001-LCOL - UAT - TEC: Contrataci?n
         ELSIF NVL(f_parproductos_v(psproduc, 'ALTA_CON_POL_PDTE'), 0) = 2 THEN
            --Solo una póliza con creteni diferente de 0
            SELECT COUNT(1)
              INTO num_err
              FROM riesgos r, seguros s
             WHERE r.sseguro = s.sseguro
               AND r.sperson = vspereal
               AND r.sseguro <> vssegpol
               AND s.sproduc = psproduc
               AND s.creteni NOT IN(0, 3, 4)
               AND s.csituac IN(4, 5);

            -- y no sean prop.alta anuladas o rechazadas.;
            IF num_err > 0 THEN
               RETURN 151241;
            END IF;
         END IF;
      -- Fin Bug 0020671
      END IF;

      -- actualizmos la tabla asegurados con el sperson que hay grabado en riesgos
      FOR c IN riesgos LOOP
         UPDATE estassegurats
            SET sperson = NVL(c.sperson, psperson)
          WHERE sseguro = psseguro
            AND norden = c.nriesgo;
      END LOOP;

      --Para cada uno de los riesgos que no tienen un asegurado los insertamos
      IF vcobjase = 1 THEN
         FOR c IN asegurados LOOP
            BEGIN
               DELETE      estassegurats
                     WHERE sseguro = psseguro
                       AND norden = c.nriesgo;

               INSERT INTO estassegurats
                           (sseguro, sperson, norden, cdomici, ffecini, nriesgo,
                            ffecfin)   -- BUG11183:DRA:08/10/2009
                    VALUES (psseguro, c.sperson, c.nriesgo, c.cdomici, c.fefecto, c.nriesgo,
                            c.fanulac);   -- BUG11183:DRA:08/10/2009
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estassegurats
                     SET cdomici = c.cdomici,
                         sperson = c.sperson,
                         ffecini = c.fefecto,
                         nriesgo = c.nriesgo   -- BUG11183:DRA:08/10/2009
                   WHERE sseguro = psseguro
                     AND norden = c.nriesgo;
            END;
         END LOOP;
      ELSE
         FOR c IN asegurados2 LOOP
            BEGIN
               DELETE      estassegurats
                     WHERE sseguro = psseguro
                       AND norden = c.nriesgo;

               INSERT INTO estassegurats
                           (sseguro, sperson, norden,
                            cdomici, ffecini, nriesgo, ffecfin)   -- BUG11183:DRA:08/10/2009
                    VALUES (psseguro, NVL(c.sperson, psperson), c.nriesgo,
                            NVL(c.cdomici, pcdomici), c.fefecto, c.nriesgo, c.fanulac);   -- BUG11183:DRA:08/10/2009
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estassegurats
                     SET cdomici = NVL(c.cdomici, pcdomici),
                         sperson = NVL(c.sperson, psperson),
                         ffecini = c.fefecto,
                         nriesgo = c.nriesgo   -- BUG11183:DRA:08/10/2009
                   WHERE sseguro = psseguro
                     AND norden = c.nriesgo;
            END;
         END LOOP;
      END IF;

      num_err := f_valida_risc_vin(psproduc, psseguro, psperson);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 101903;   --AsseguranÃ§a no trobada
      WHEN OTHERS THEN
         RETURN 101903;   --AsseguranÃ§a no trobada
   END f_valida_estriesgo;

   FUNCTION f_motivo_retencion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER)
      RETURN NUMBER IS
      cont           NUMBER;
      n_nmotret      NUMBER;
      s_ssegpol      estseguros.ssegpol%TYPE;
   BEGIN
      BEGIN
         SELECT ssegpol
           INTO s_ssegpol
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 103286;   --{L'asseguranÃ§a no existeix}
      END;

      BEGIN
         SELECT MAX(motret)
           INTO n_nmotret
           FROM ((SELECT NVL(MAX(nmotret), 0) + 1 motret
                    FROM estmotretencion
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND nmovimi = pnmovimi
                  UNION
                  SELECT NVL(MAX(nmotret), 0) + 1 motret
                    FROM motretencion
                   WHERE sseguro = s_ssegpol
                     AND nriesgo = pnriesgo
                     AND nmovimi = pnmovimi));
      END;

      BEGIN
         -- insertamos la retención
         INSERT INTO estmotretencion
                     (nmotret, sseguro, nriesgo, nmovimi, cmotret, cusuret,
                      freten)
              VALUES (n_nmotret, psseguro, pnriesgo, pnmovimi, pcmotret, f_user,
                      TRUNC(f_sysdate));
      -- actualizamos seguros a retenido
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151725;   --{Error al retener la póliza}
      END;

      UPDATE estseguros
         SET creteni = 1   --{Retención voluntaria}
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 140999;   --{error no controlado}
   END f_motivo_retencion;

   FUNCTION f_ins_estpregunseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      INSERT INTO estpregunseg
                  (sseguro, nriesgo, nmovimi, cpregun, crespue)
           VALUES (psseguro, pnriesgo, pnmovimi, pcpregun, pcrespue);

      RETURN 0;
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE estpregunseg
            SET crespue = pcrespue
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cpregun = pcpregun;

         RETURN 0;
      WHEN OTHERS THEN
         RETURN 108426;   --error en al insertar preguntas
   END f_ins_estpregunseg;

   --(JAS)11.12.2007 - Gestió de preguntes per pòlissa
   FUNCTION f_valida_estpregunseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      tipo OUT NUMBER,
      campo OUT VARCHAR2)
      RETURN NUMBER IS
      w_ret          NUMBER := 0;
      -- jlb
      vissimul       NUMBER(1) := 0;
      v_isaltacol    NUMBER(1) := 0;

      CURSOR c_existpreg(
         pc_in_sseguro IN estpregunseg.sseguro%TYPE,
         pc_in_nriesgo IN estpregunseg.nriesgo%TYPE,
         pc_in_sproduc IN pregunpro.sproduc%TYPE) IS
         --SELECT 1
         SELECT cpregun
           FROM (SELECT cpregun
                   FROM pregunpro p
                  WHERE p.sproduc = pc_in_sproduc
                    AND p.cpreobl = 1   --obligatorias
                    AND p.cpretip <> 2
                    -- jlb
                    AND((p.cofersn <> 2
                         AND vissimul = 0)
                        OR(p.cofersn = 1
                           AND vissimul = 1))
                    AND p.cnivel = 'R'
                    AND((p.visiblecol = 1
                         AND v_isaltacol = 1)
                        OR(v_isaltacol = 0
                           AND p.visiblecert = 1))
                 MINUS
                 SELECT cpregun
                   FROM estpregunseg
                  WHERE sseguro = pc_in_sseguro
                    AND nriesgo = pc_in_nriesgo)
          WHERE ROWNUM = 1;
   BEGIN
      -- jlb -- no deberia acceder a esta variable, pero por rendimiento y es pantalla o cargas estará informada
      -- no toco lo de abajo para no afectar
      IF pac_iax_produccion.isaltacol THEN
         isaltacol := TRUE;
      ELSE
         isaltacol := FALSE;
      END IF;

      IF isaltacol THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      -- jlb
      IF pac_iax_produccion.issimul THEN
         vissimul := 1;
      END IF;

      <<l_existpreg>>
      FOR reg_existpreg IN c_existpreg(psseguro, pnriesgo, psproduc) LOOP
         tipo := 5;
         -- campo := NULL;
         campo := reg_existpreg.cpregun;
         w_ret := 120307;
      END LOOP l_existpreg;

      RETURN w_ret;
   END f_valida_estpregunseg;

   FUNCTION f_obtener_digitoctr_bm(pcbancar IN VARCHAR2, pctipban IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      TYPE digito IS RECORD(
         produc         NUMBER,
         decena         VARCHAR2(2),
         unidad         VARCHAR2(1),
         numero         NUMBER
      );

      tproduc        VARCHAR2(3);

      TYPE tabla IS TABLE OF digito
         INDEX BY BINARY_INTEGER;

      cuenta         VARCHAR2(20);
      control        tabla;
      unidades       NUMBER := 0;
      decenas        NUMBER := 0;
      total          NUMBER;
   BEGIN
      IF pctipban = 1 THEN   --> Només funciona per comptes Espanyoles
         cuenta := LPAD(pcbancar, 19, '0');

         FOR i IN 1 .. 19 LOOP
            control(i).numero := SUBSTR(cuenta, i, 1);

            IF MOD(i, 3) = 0 THEN
               control(i).produc := (control(i).numero) * 2;
            ELSIF MOD(i, 3) = 1 THEN
               control(i).produc := control(i).numero * 1;
            ELSE
               control(i).produc := control(i).numero * 31;
            END IF;

            tproduc := LPAD(control(i).produc, 3, '0');
            control(i).unidad := TO_NUMBER(SUBSTR(tproduc, LENGTH(tproduc), 1));
            control(i).decena := NVL(TO_NUMBER(SUBSTR(tproduc, LENGTH(tproduc) - 1, 1)), 0);
            unidades := unidades + control(i).unidad;
            decenas := decenas + control(i).decena;
         END LOOP;

         total := unidades + decenas;
         RETURN TO_NUMBER(SUBSTR(total, LENGTH(total), 1));
      END IF;

      RETURN NULL;
   END f_obtener_digitoctr_bm;

   FUNCTION f_obtener_cuenta010_bm(pcbancar IN VARCHAR2, pctipban IN NUMBER DEFAULT 1)
      RETURN VARCHAR2 IS
      vcentro        VARCHAR2(4);
      vofi           VARCHAR2(3);
      vcon           VARCHAR2(6);
      vafi           VARCHAR2(2);
   BEGIN
      IF pctipban = 1 THEN   --> Només funciona per comptes Espanyoles
         vcentro := SUBSTR(pcbancar, 5, 4);

         IF vcentro = '0001'
            OR vcentro = '0002'
            OR vcentro = '0103' THEN
            vofi := '000';
         ELSE
            vofi := SUBSTR(pcbancar, 6, 3);
         END IF;

         vcon := SUBSTR(pcbancar, 11, 6);
         vafi := SUBSTR(pcbancar, 18, 2);
         RETURN(vofi || vcon || vafi || '00000');
      END IF;
   END f_obtener_cuenta010_bm;

   FUNCTION ff_calcula_capital(psproduc IN NUMBER, pcactivi IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER IS
      /************************************************************************************************************
         Función que retorna:
             0.- si se debe calcular el capital calculado en la tarificación
             1.- si se debe calcular el capital calculado al seleccionar la garantía
      **********************************************************************************************************/
      v_clave        garanformula.clave%TYPE;
   BEGIN
      -- Miraremos si hay formula de capital calculado en la tarificación
      BEGIN
         BEGIN
            SELECT clave
              INTO v_clave
              FROM garanformula
             WHERE (cramo, cmodali, ctipseg, ccolect) =
                                                      (SELECT cramo, cmodali, ctipseg, ccolect
                                                         FROM productos
                                                        WHERE sproduc = psproduc)
               AND ccampo IN('ICAPCAL', 'CAPCALPS')   -- BUG9496:17/03/2009:DRA
               AND cgarant = pcgarant
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- BUG22279:DRA:21/06/2012:Analizamos la actividad
               SELECT clave
                 INTO v_clave
                 FROM garanformula
                WHERE (cramo, cmodali, ctipseg, ccolect) =
                                                      (SELECT cramo, cmodali, ctipseg, ccolect
                                                         FROM productos
                                                        WHERE sproduc = psproduc)
                  AND ccampo IN('ICAPCAL', 'CAPCALPS')   -- BUG9496:17/03/2009:DRA
                  AND cgarant = pcgarant
                  AND cactivi = 0;
         END;

         RETURN 0;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 1;
      END;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.ff_calcula_capital', NULL,
                     'parametros: psproduc =' || psproduc || 'pcactivi =' || pcactivi
                     || 'pcgarant =' || pcgarant,
                     SQLERRM);
         RETURN NULL;
   END ff_calcula_capital;

   /*********************************
    f_garanpro_estgaranseg : Inicializa garantías y sus capitales

    param in psseguro: seguro
    param in pnriesgo: riesgo
    param in pnmovimi: nmovimi
    param in psproduc: código producto
    param in pfefecto: fecha de efecto
    param in pcactivi: actividad

    retorna 0 si todo ha ido bien o un código de error
   *********************************/
   FUNCTION f_garanpro_estgaranseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcactivi IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      /******************************************************************************
       función que traspasa la información de garanpro  a las tablas EST.
      ******************************************************************************/
      CURSOR gar_no_contratadas(
         p_sseguro IN NUMBER,
         p_nriesgo IN NUMBER,
         p_sproduc IN NUMBER,
         p_cactivi IN NUMBER) IS
         -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = p_sproduc
            AND cactivi = p_cactivi
            AND NVL(cofersn, 0) <> 2
         UNION
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = p_sproduc
            AND cactivi = 0
            AND NVL(cofersn, 0) <> 2
            AND NOT EXISTS(SELECT cgarant
                             FROM garanpro
                            WHERE sproduc = p_sproduc
                              AND cactivi = p_cactivi
                              AND NVL(cofersn, 0) <> 2)
         MINUS
         SELECT cgarant
           FROM estgaranseg
          WHERE sseguro = p_sseguro
            AND nriesgo = p_nriesgo;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      CURSOR garantias_contratadas IS
         SELECT cgarant, ctipgar, nmovima
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND ctipgar IS NULL;

      -- BUG10494:DRA:07/09/2009:Inici
      CURSOR c_pre(pc_cgarant IN NUMBER) IS
         SELECT p.cpregun
           FROM pregunprogaran p
          WHERE p.sproduc = psproduc
            AND p.cactivi = pcactivi
            AND p.cgarant = pc_cgarant
            AND p.cpregun NOT IN(SELECT ep.cpregun
                                   FROM estpregungaranseg ep
                                  WHERE ep.sseguro = psseguro
                                    AND ep.nriesgo = pnriesgo
                                    AND ep.cgarant = pc_cgarant)
         UNION
         SELECT p.cpregun
           FROM pregunprogaran p
          WHERE p.sproduc = psproduc
            AND p.cactivi = 0
            AND p.cgarant = pc_cgarant
            AND p.cpregun NOT IN(SELECT ep.cpregun
                                   FROM estpregungaranseg ep
                                  WHERE ep.sseguro = psseguro
                                    AND ep.nriesgo = pnriesgo
                                    AND ep.cgarant = pc_cgarant)
            AND NOT EXISTS(SELECT 1
                             FROM pregunprogaran
                            WHERE sproduc = psproduc
                              AND cactivi = pcactivi
                              AND cgarant = pc_cgarant);

      -- BUG10494:DRA:07/09/2009:Fi
      reg_gar        garanpro%ROWTYPE;
      reg_seg        estseguros%ROWTYPE;
      vcobliga       NUMBER;
      vicapital      garanpro.icapmax%TYPE;
      num_err        NUMBER;
      vmensa         VARCHAR2(100);
      v_cpregun      pregunprogaran.cpregun%TYPE;
      v_pasexec      NUMBER;
      v_cactivi      NUMBER;
      v_ftarifa      DATE;   -- Bug 18848 - APD - 22/06/2011
      v_contrata_gar_defecto NUMBER;   --Bug 21846 - APD - 29/03/2012
   BEGIN
      v_pasexec := 0;

       -- Si existen y el ctipgar no está quiere decir que la póliza
      -- ya está creada y que las garantías han sido traspasadas con
      -- el pac_alctr126, rellenamos su tipo de garantia,la fecha de
      -- efecto, y ponemos su cobliga =1
      SELECT *
        INTO reg_seg
        FROM estseguros
       WHERE sseguro = psseguro;

      v_pasexec := 1;

      -- Bug 18848 - APD - 22/06/2011
      -- si 'FECHA_TARIFA' = 1.- Fecha de efecto --> tal y como funciona hasta ahora
      -- si 'FECHA_TARIFA' = 2.- Fecha de grabacion inicial --> FTARIFA = F_SYSDATE
      IF NVL(f_parproductos_v(psproduc, 'FECHA_TARIFA'), 1) = 1 THEN   -- Fecha de efecto
         v_ftarifa := TO_DATE(frenovacion(1, psseguro, 1), 'yyyymmdd');
      ELSIF NVL(f_parproductos_v(psproduc, 'FECHA_TARIFA'), 1) = 2 THEN   -- Fecha de grabacion inicial
         v_ftarifa := TRUNC(f_sysdate);
      END IF;

      -- Fin Bug 18848 - APD - 22/06/2011
      FOR c IN garantias_contratadas LOOP
         BEGIN
            SELECT *
              INTO reg_gar
              FROM garanpro
             WHERE cgarant = c.cgarant
               AND cactivi = pcactivi
               AND sproduc = psproduc;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT *
                 INTO reg_gar
                 FROM garanpro
                WHERE cgarant = c.cgarant
                  AND cactivi = 0
                  AND sproduc = psproduc;
         END;

         v_pasexec := 2;

         -- hay que poner las que ya existen en estseguros como contratadas.
         -- Ini IAXIS-3631 -- ECP -- 16/05/2019
         begin
         UPDATE estgaranseg
            SET cobliga = 1,
                finiefe = pfefecto,
                ffinefe = NULL,
                ctipgar = reg_gar.ctipgar
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = c.cgarant;
            exception when no_data_found then null;
            end;
-- Fin IAXIS-3631 -- ECP -- 16/05/2019
          -- borramos e insertamos por si hay alguna pregunta que no tengamos y sea necesaria
         -- DELETE      estpregungaranseg
           --     WHERE sseguro = psseguro
             --     AND nriesgo = pnriesgo
               --   AND cgarant = c.cgarant;
         v_pasexec := 3;
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
         -- BUG10494:DRA:07/09/2009:Inici

         -- Bug 19808 - RSC - 14/11/2011 - LCOL_T004-Parametrización de suplementos
         /*FOR r_pre IN c_pre(c.cgarant) LOOP
            v_pasexec := 5;

            IF r_pre.cpregun IS NOT NULL THEN
               INSERT INTO estpregungaranseg
                           (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, trespue,
                            nmovima, finiefe)
                    VALUES (psseguro, pnriesgo, c.cgarant, pnmovimi, r_pre.cpregun, 0, NULL,
                            c.nmovima, pfefecto);
            END IF;
         END LOOP;*/
         -- Fin Bug 19808

         -- BUG10494:DRA:07/09/2009:Fi
         v_pasexec := 6;
      /* SELECT psseguro, pnriesgo, c.cgarant, pnmovimi, cpregun, 0, '', c.nmovima,
                pfefecto
           FROM pregunprogaran
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = c.cgarant
            AND cpregun IN(SELECT cpregun
                             FROM pregunprogaran
                            WHERE sproduc = psproduc
                              AND cactivi = pcactivi
                              AND cgarant = c.cgarant
                           MINUS
                           SELECT cpregun
                             FROM estpregungaranseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND cgarant = c.cgarant); */                                                                                                                                                                                                                                                                                                                                                              -- Bug 9699 - APD - 08/04/2009 - Fin
      END LOOP;

      FOR g IN gar_no_contratadas(psseguro, pnriesgo, psproduc, pcactivi) LOOP
         --   Por cada garantía que exista en garanpro y no exista en estgaranseg
         --   obtenemos la información y la insertamos en estgaranseg
         v_pasexec := 7;

         BEGIN
            SELECT *
              INTO reg_gar
              FROM garanpro
             WHERE cgarant = g.cgarant
               AND sproduc = psproduc
               AND cactivi = pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'EST');
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_pasexec := 8;

               SELECT *
                 INTO reg_gar
                 FROM garanpro
                WHERE cgarant = g.cgarant
                  AND sproduc = psproduc
                  AND cactivi = 0;
         END;

         v_pasexec := 9;
         --Bug 21846 - APD - 29/03/2012 - se deben marcar como obligatorias
         -- aquellas garantias parametrizadas
         v_contrata_gar_defecto :=
            NVL(pac_parametros.f_pargaranpro_n(psproduc,
                                               pac_seguros.ff_get_actividad(psseguro, pnriesgo,
                                                                            'EST'),
                                               g.cgarant, 'CONTRATADA_DEFECTO'),
                0);

         -- v_contrata_gar_defecto
         -- 0.- No
         -- 1.- Sí, en contratación
         -- 2.- Sí, en contratación y suplementos
         -- Si 1.- Sí, en contratación y pnmovimi = 1 (contratacion)
         -- o 2.- Sí, en contratación y suplementos
         -- entonces marcar la garantia como obligatoria, es decir, seleccionada
         --fin Bug 21846 - APD - 29/03/2012

         --Si es obligatoria la marcamos como contratada
         -- Bug 21846 - APD - 29/03/2012 - se aNade el OR v_contrata_gar_defecto = 2
         IF reg_gar.ctipgar = 2
            OR v_contrata_gar_defecto = 2 THEN
            -- fin Bug 21846 - APD - 29/03/2012
            v_pasexec := 10;

            IF f_validar_edad(psseguro, pnriesgo, psproduc,
                              pac_seguros.ff_get_actividad(psseguro, pnriesgo, 'EST'),
                              g.cgarant) = 0
               AND f_valida_exclugarseg('EST', psseguro, pnriesgo, g.cgarant) = 0
               AND f_validar_siniestro('EST', psseguro, pnriesgo, g.cgarant) =
                     0   --Bug. 8947 - ICV - 02/06/2009 - Comprueba si se ha anulado la garantia por siniestro
                      THEN
               v_pasexec := 11;
               vcobliga := 1;

               --informamos el k segun el tipo de kapital de la garantia
               IF reg_gar.ctipcap = 1 THEN
                  vicapital := reg_gar.icapmax;
               -- Ini Bug 21707 - 20/03/2012 - MDS
               ELSIF reg_gar.ctipcap = 2 THEN
                  vicapital :=
                     pac_parametros.f_pargaranpro_n(psproduc,
                                                    pac_seguros.ff_get_actividad(psseguro,
                                                                                 pnriesgo,
                                                                                 'EST'),
                                                    g.cgarant, 'VALORDEFCAPITALGARAN');
               -- fin Bug 21707 - 20/03/2012 - MDS
               ELSIF reg_gar.ctipcap = 4 THEN
                  vicapital := 0;
               ELSIF reg_gar.ctipcap = 5 THEN
                  -- BUG25037:DRA:14/12/2012: En el IF no entrará nunca
                  IF ff_calcula_capital(psproduc, pcactivi, g.cgarant) = 1 THEN
                     num_err := f_calculo_capital_calculado(pfefecto, psseguro, pcactivi,
                                                            g.cgarant, pnriesgo, pnmovimi, 1,
                                                            vicapital);

                     IF num_err <> 0 THEN
                        vicapital := 0;
                     END IF;
                  ELSE
                     --  Bug 10898 - 19/08/2009 - JRH - Mantener Capitales migrados en productos de salud al realizar suplemento
                     vicapital := 0;   --Si no da problemas en los capitales calculados si icapital=null
                  -- fi Bug 10898 - 19/08/2009 - JRH
                  END IF;
               ELSE
                  vicapital := NULL;
               END IF;

               v_pasexec := 12;
            ELSE   -- si no cumplen la edad ya no son obligatorias
               vcobliga := 0;
               vicapital := NULL;
            END IF;

            v_pasexec := 13;

            -- calculamos el k si es un prod de ahorro y es base_capital
            -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            IF f_prod_vinc(psproduc) = 1
               AND f_pargaranpro_v(reg_seg.cramo, reg_seg.cmodali, reg_seg.ctipseg,
                                   reg_seg.ccolect,
                                   pac_seguros.ff_get_actividad(reg_seg.sseguro, pnriesgo,
                                                                'EST'),
                                   g.cgarant, 'BASE_CAPITAL') = 1 THEN
               v_pasexec := 14;
               num_err := f_obtener_estcap_vin(psseguro, vicapital);

               IF num_err <> 0 THEN
                  vicapital := NULL;
               END IF;
            END IF;
         -- Bug 9699 - APD - 23/04/2009 - Fin
         ELSE
            vcobliga := 0;
            vicapital := NULL;
         END IF;

         v_pasexec := 15;

         -- Bug 18848 - APD - 22/06/2011
         -- se sustituye el valor TO_DATE(frenovacion(1, psseguro, 1), 'yyyymmdd') por v_ftarifa
         -- que será el que se inserte en el campo estgaranseg.ftarifa
         -- Ini IAXIS-3631 -- ECP -- 16/05/2019
         INSERT INTO estgaranseg
                     (sseguro, nriesgo, nmovimi, cgarant, finiefe, ffinefe,
                      crevali, prevali, irevali, ifranqu,
                      ctarifa, nparben, nbns, icapital, cobliga,
                      norden, ctipgar,
                      ftarifa, nmovima,
                      cderreg)   -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
              VALUES (psseguro, pnriesgo, pnmovimi, reg_gar.cgarant, pfefecto, NULL,
                      nvl(reg_gar.crevali,0), reg_gar.prevali, reg_gar.irevali, reg_gar.ifranqu,
                      reg_gar.ctarifa, reg_gar.nparben, reg_gar.nbns, vicapital, vcobliga,
                      reg_gar.norden, reg_gar.ctipgar,
                      v_ftarifa /*TO_DATE(frenovacion(1, psseguro, 1), 'yyyymmdd')*/, pnmovimi,
                      reg_gar.cderreg);   -- Bug 0019578 - FAL - 26/09/2011 - Recuperar si derechos de registro nivel garantia
-- Ini IAXIS-3631 -- ECP -- 16/05/2019
         -- Fin Bug 18848 - APD - 22/06/2011
         v_pasexec := 16;
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
          -- insertamos las preguntas de las garantias
         /*
         INSERT INTO estpregungaranseg
                     (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, trespue, nmovima,
                      finiefe)
            SELECT psseguro, pnriesgo, reg_gar.cgarant, pnmovimi, cpregun, 0, NULL, pnmovimi,
                   pfefecto
              FROM pregunprogaran
             WHERE sproduc = psproduc
               AND cactivi = pcactivi
               AND cgarant = reg_gar.cgarant
            UNION
            SELECT psseguro, pnriesgo, reg_gar.cgarant, pnmovimi, cpregun, 0, NULL, pnmovimi,
                   pfefecto
              FROM pregunprogaran
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = reg_gar.cgarant
               AND NOT EXISTS(SELECT 1
                                FROM pregunprogaran
                               WHERE sproduc = psproduc
                                 AND cactivi = pcactivi
                                 AND cgarant = reg_gar.cgarant);
         */
      -- Bug 9699 - APD - 08/04/2009 - Fin
      END LOOP;

      v_pasexec := 17;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_garanpro_estgaranseg',
                     v_pasexec, 'Error no controlat', SQLERRM);
         RETURN 105577;   -- Error al modificar las garantías
   END f_garanpro_estgaranseg;

   FUNCTION f_claubenseg_estclau(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      psproduc NUMBER)
      RETURN NUMBER IS
      /******************************************************************************
        Traspaso de clausulas beneficiario  a las tablas EST
      ******************************************************************************/
      CURSOR clau(p_sseguro IN NUMBER, p_nriesgo IN NUMBER, p_nmovimi IN NUMBER) IS
         SELECT sclaben
           FROM clausuben
          WHERE sclaben IN(SELECT sclaben
                             FROM claubenpro
                            WHERE sproduc = psproduc)
         MINUS
         SELECT sclaben
           FROM estclaubenseg
          WHERE sseguro = p_sseguro
            AND nriesgo = p_nriesgo
            AND nmovimi = p_nmovimi;

      vsclaben       productos.sclaben%TYPE;
      contador       NUMBER;
   BEGIN
      --PRODUCTOS sclaben, si hay alguna grabada hay que ponerla a obliga a 1
      UPDATE estclaubenseg
         SET finiclau = TRUNC(pfefecto),
             ffinclau = NULL
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi;

      FOR c IN clau(psseguro, pnriesgo, pnmovimi) LOOP
         INSERT INTO estclaubenseg
                     (nmovimi, sclaben, sseguro, nriesgo, finiclau, ffinclau, cobliga)
              VALUES (pnmovimi, c.sclaben, psseguro, pnriesgo, TRUNC(pfefecto), NULL, 0);
      END LOOP;

      SELECT COUNT(1)
        INTO contador
        FROM (SELECT sseguro
                FROM estclaubenseg
               WHERE sseguro = psseguro
                 AND nriesgo = pnriesgo
                 AND nmovimi = pnmovimi
                 AND cobliga IS NULL
              UNION
              SELECT sseguro
                FROM estclausuesp
               WHERE sseguro = psseguro
                 AND nriesgo = pnriesgo
                 AND nmovimi = pnmovimi
                 AND cclaesp = 1);

      IF contador = 0 THEN
         SELECT sclaben
           INTO vsclaben
           FROM productos
          WHERE sproduc = psproduc;

         UPDATE estclaubenseg
            SET cobliga = 1
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND sclaben = vsclaben;
      ELSE
         UPDATE estclaubenseg
            SET cobliga = 1
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cobliga IS NULL;
      END IF;

      RETURN 0;
   END f_claubenseg_estclau;

   FUNCTION f_valida_clausulas(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
      contador       NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO contador
        FROM (SELECT sseguro
                FROM estclaubenseg
               WHERE sseguro = psseguro
                 AND nriesgo = pnriesgo
                 AND nmovimi = pnmovimi
                 AND cobliga = 1
              UNION
              SELECT sseguro
                FROM estclausuesp
               WHERE sseguro = psseguro
                 AND nriesgo = pnriesgo
                 AND nmovimi = pnmovimi
                 AND tclaesp IS NOT NULL
                 AND cclaesp = 1);

      IF contador = 1 THEN
         RETURN 0;
      ELSIF contador = 0 THEN
         RETURN 101817;   --Quedan clausulas de beneficiario por informar
      ELSE
         RETURN 151223;
      --Hay más de una cláusula de beneficiario selecionada.
      END IF;

      RETURN 0;
   END f_valida_clausulas;

   --- Cláusulas genericas
   FUNCTION f_valida_clausulas_gen(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      RETURN 0;
   END f_valida_clausulas_gen;

   -- BUG25037:DRA:13/12/2012:Inici
   FUNCTION f_garantia_contratada(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER)
      RETURN NUMBER IS
      --
      v_existe       NUMBER;
      v_ssegpol      estseguros.ssegpol%TYPE;
   BEGIN
      SELECT ssegpol
        INTO v_ssegpol
        FROM estseguros
       WHERE sseguro = p_sseguro;

      SELECT COUNT(1)
        INTO v_existe
        FROM garanseg g
       WHERE g.sseguro = v_ssegpol
         AND g.nriesgo = p_nriesgo
         AND g.cgarant = p_cgarant
         AND g.nmovimi < p_nmovimi
         AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                            FROM garanseg g1
                           WHERE g1.sseguro = g.sseguro
                             AND g1.nriesgo = g.nriesgo
                             AND g1.cgarant = g.cgarant);

      IF v_existe > 0 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END f_garantia_contratada;

   -- BUG25037:DRA:13/12/2012:Fi
   FUNCTION f_validacion_cobliga(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      paccion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima NUMBER DEFAULT 1)
      RETURN NUMBER IS
      --
      CURSOR garantias(
         p_sseguro IN NUMBER,
         p_nriesgo IN NUMBER,
         p_nmovimi IN NUMBER,
         p_cgarant IN NUMBER,
         p_nmovima IN NUMBER) IS
         SELECT cgarant, ctipgar, cobliga, icapital, pdtocom, iprianu, precarg, iextrap,
                nmovima, finiefe
           FROM estgaranseg
          WHERE sseguro = p_sseguro
            AND nmovimi = p_nmovimi
            AND nriesgo = p_nriesgo
            AND cgarant = p_cgarant
            AND nmovima = p_nmovima;

      CURSOR garantias_hijas_capital(psproduc IN NUMBER, pcgarant IN NUMBER) IS
         SELECT g.cgarant, s.cobliga, s.sseguro, s.nriesgo, s.nmovimi, s.nmovima
           FROM garanpro g, estgaranseg s
          WHERE g.cgardep = pcgarant
            AND g.sproduc = psproduc
            AND s.sseguro = psseguro
            AND s.nmovimi = pnmovimi
            AND s.nmovima = pnmovima
            AND s.nriesgo = pnriesgo
            AND s.cgarant = g.cgarant
            AND s.cobliga = 1
            AND g.ctipcap IN(3, 6);

      num_err        NUMBER := 0;
      num_err2       NUMBER := 0;
      gpro_reg       garanpro%ROWTYPE;
      seg_reg        estseguros%ROWTYPE;
      vcobliga       estgaranseg.cobliga%TYPE;
      vicapital      estgaranseg.icapital%TYPE;
      vpdtocom       estgaranseg.pdtocom%TYPE;
      viprianu       estgaranseg.iprianu%TYPE;
      vprecarg       estgaranseg.precarg%TYPE;
      viextrap       estgaranseg.iextrap%TYPE;
      tipo           NUMBER;
      mens           NUMBER;
      ex_update      EXCEPTION;
      vicapital_bck  estgaranseg.icapital%TYPE;
      v_modif_capital BOOLEAN := FALSE;
      -- Bug 11735 - RSC - 27/01/2010 - APR - suplemento de modificación de capital /prima
      v_tariff       NUMBER;
      -- Fin Bug 11735
      v_retorno      NUMBER := 0;
      v_existe       NUMBER;
   BEGIN
      BEGIN
         SELECT *
           INTO gpro_reg
           FROM garanpro
          WHERE cgarant = pcgarant
            AND sproduc = psproduc
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO gpro_reg
              FROM garanpro
             WHERE cgarant = pcgarant
               AND sproduc = psproduc
               AND cactivi = 0;
      END;

      SELECT *
        INTO seg_reg
        FROM estseguros
       WHERE sseguro = psseguro;

      FOR c IN garantias(psseguro, pnriesgo, pnmovimi, pcgarant, pnmovima) LOOP
         vcobliga := c.cobliga;
         vicapital := c.icapital;
         vpdtocom := c.pdtocom;
         viprianu := c.iprianu;
         vprecarg := c.precarg;
         viextrap := c.iextrap;

         IF c.ctipgar IN(2, 9)
            AND c.cobliga <> 1
            AND f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi, c.cgarant) = 0
            AND f_valida_exclugarseg('EST', psseguro, pnriesgo, pcgarant) = 0 THEN
            --validamos la edad, y solo marcamos aquella que cumplen la edad.
            -- no devolvemos el error si no que las que ni cumplen no se marcan
            vcobliga := 1;

            IF c.ctipgar = 9 THEN
               vicapital := 0;
            END IF;

            num_err := 101656;   --error pero continuamos
            RAISE ex_update;
         END IF;

         IF c.cobliga = 1 THEN
            tipo := f_prod_ahorro(seg_reg.sproduc);

            BEGIN
               SELECT sseguro
                 INTO v_existe
                 FROM seguros
                WHERE sseguro = seg_reg.ssegpol;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_existe := 0;
            END;

            IF v_existe > 0
               AND f_pargaranpro_v(seg_reg.cramo, seg_reg.cmodali, seg_reg.ctipseg,
                                   seg_reg.ccolect,
                                   pac_seguros.ff_get_actividad(seg_reg.sseguro, pnriesgo,
                                                                'EST'),
                                   c.cgarant, 'TIPO') = 4
               AND NVL(f_parproductos_v(seg_reg.sproduc, 'SUPL_EXTRA_UNICA'), 0) = 1 THEN   -- Si es suplemento y el producto tiene el parámetro
               NULL;
            ELSE
               -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               IF tipo = 1
                  AND seg_reg.cforpag = 0
                  AND f_pargaranpro_v(seg_reg.cramo, seg_reg.cmodali, seg_reg.ctipseg,
                                      seg_reg.ccolect,
                                      pac_seguros.ff_get_actividad(seg_reg.sseguro, pnriesgo,
                                                                   'EST'),
                                      c.cgarant, 'TIPO') = 4 THEN
                  vcobliga := 0;
                  vicapital := NULL;
                  viprianu := NULL;
                  num_err := 151242;
                  RAISE ex_update;
               END IF;
            -- Bug 9699 - APD - 23/04/2009 - fin
            END IF;

            -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            num_err := f_valida_incompatibles(c.cgarant, c.cobliga, seg_reg.sseguro, pnriesgo,
                                              seg_reg.cramo, seg_reg.cmodali, seg_reg.ctipseg,
                                              seg_reg.ccolect,
                                              pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                           pnriesgo, 'EST'),
                                              pmensa);

            -- Bug 9699 - APD - 23/04/2009 - fin
            IF num_err = 0 THEN
               -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               num_err := f_marcar_dep_obliga(paccion, psproduc,
                                              pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                           pnriesgo, 'EST'),
                                              c.cgarant, psseguro, pnriesgo, pnmovimi, pmensa,
                                              c.nmovima);
               -- Bug 9699 - APD - 23/04/2009 - fin

               --Bug.: 18350 - ICV - 01/05/2011
               -- Bug 21786 - APD - 27/03/2012 - se comenta el IF
               --IF c.ctipgar NOT IN(5, 6) THEN
               -- fin Bug 21786 - APD - 27/03/2012
               num_err :=
                  pk_nueva_produccion.f_marcar_dep_multiples
                                              (paccion, psproduc,
                                               pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                            pnriesgo, 'EST'),
                                               c.cgarant, psseguro, pnriesgo, pnmovimi,
                                               pmensa, c.nmovima);

               IF num_err <> 0 THEN
                  RAISE ex_update;
               END IF;

               -- Bug 21786 - APD - 27/03/2012 - se aNade aqui el IF
               --ELSE
               IF c.ctipgar IN(5, 6) THEN
                  -- fin Bug 21786 - APD - 27/03/2012
                  v_retorno :=
                     pk_nueva_produccion.f_cumpleix_dep_multiple
                                              (psproduc,
                                               pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                            pnriesgo, 'EST'),
                                               c.cgarant, psseguro, pnriesgo, pnmovimi,
                                               pmensa, c.nmovima);

                  IF c.ctipgar = 5 THEN
                     IF NVL(v_retorno, 0) <> 1 THEN
                        vcobliga := 0;

                        -- Bug 21786 - APD - 21/05/2012 - se debe distinguir entre el mensaje
                        -- que debe mostrarse si v_retorno =  0 o v_retorno = num_err
                        IF NVL(v_retorno, 0) = 0 THEN
                           num_err := 108388;   --No se cumplena las dependencias opcionales
                        ELSE
                           num_err := v_retorno;
                        END IF;

                        -- fin Bug 21786 - APD - 21/05/2012
                        RAISE ex_update;
                     -- Bug 23196 - APD - 04/09/2012 - se comenta el else para que continue el
                     -- código (no salga por el RAISE) igual que en el caso de ctipgar = 6
                     /*ELSE
                        vicapital := 0;
                        RAISE ex_update;
                     */
                     -- fin Bug 23196 - APD - 04/09/2012
                     END IF;
                  ELSIF c.ctipgar = 6 THEN
                     -- Bug 21786 - APD - 21/05/2012 - se debe distinguir entre el mensaje
                     -- que debe mostrarse si v_retorno =  0 o v_retorno = num_err
                     IF NVL(v_retorno, 0) <> 1 THEN
                        -- Bug 22964 - APD - 04/09/2012 - la variable vcobliga = 0 debe estar
                        -- fuera del IF NVL(v_retorno, 0) = 0 THEN
                        vcobliga := 0;

                        -- fin Bug 22964 - APD - 04/09/2012
                        IF NVL(v_retorno, 0) = 0 THEN
                           num_err := 108388;   --No se cumplena las dependencias obligatorias
                        ELSE
                           num_err := v_retorno;
                        END IF;

                        RAISE ex_update;
                     END IF;
                  -- fin Bug 21786 - APD - 21/05/2012
                  END IF;
               END IF;

               --Fi bug.: 18350

               -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               num_err :=
                  f_valida_dependencias(paccion, psproduc, seg_reg.cramo, seg_reg.cmodali,
                                        seg_reg.ctipseg, seg_reg.ccolect,
                                        pac_seguros.ff_get_actividad(seg_reg.sseguro, pnriesgo,
                                                                     'EST'),
                                        psseguro, pnriesgo, pnmovimi, c.cgarant, pmensa,
                                        c.nmovima);

               -- Bug 9699 - APD - 23/04/2009 - fin
               IF num_err = 0 THEN   --valida_dependencias
                  -- BUG25037:DRA:13/12/2012:Inici
                  IF f_garantia_contratada(psseguro, pnriesgo, pnmovimi, c.cgarant) = 0 THEN
                     -- BUG25037:DRA:13/12/2012:Fi
                     num_err := f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi,
                                               c.cgarant);

                     IF num_err <> 0 THEN   -- si falla la edad
                        --tipo de garantia
                        IF c.ctipgar = 2 THEN
                           vcobliga := 0;   --Ahora ya no son obligatorias
                           num_err := 0;
                           RAISE ex_update;
                        ELSE
                           vcobliga := 0;
                           num_err := 140468;
                           RAISE ex_update;
                        END IF;
                     END IF;
                  END IF;

                  --Ini Bug. 8947 - ICV - 02/06/2009 - ANadir comprobaciones de garantías.
                  num_err := f_valida_exclugarseg('EST', psseguro, pnriesgo, c.cgarant);

                  IF num_err <> 0 THEN   -- si falla
                     --tipo de garantia
                     IF c.ctipgar = 2 THEN
                        vcobliga := 0;   --Ahora ya no son obligatorias
                        num_err := 0;
                        RAISE ex_update;
                     ELSE
                        vcobliga := 0;
                        num_err := 9001750;
                        RAISE ex_update;
                     END IF;
                  END IF;

                  -- Bug 29488/162084 - 27/12/2013 - AMC
                  IF NVL(pac_parametros.f_pargaranpro_n(psproduc, pcactivi, c.cgarant,
                                                        'VALGARSINI_VAL_O_PSU'),
                         0) = 0 THEN
                     num_err := f_validar_siniestro('EST', psseguro, pnriesgo, c.cgarant);

                     IF num_err <> 0 THEN   -- si falla
                        --tipo de garantia
                        IF c.ctipgar = 2 THEN
                           vcobliga := 0;   --Ahora ya no son obligatorias
                           num_err := 0;
                           RAISE ex_update;
                        ELSE
                           vcobliga := 0;
                           num_err := 9001751;
                           RAISE ex_update;
                        END IF;
                     END IF;
                  END IF;

                  -- Fi Bug 29488/162084 - 27/12/2013 - AMC

                  --Fi Bug. 8947 - ICV - 02/06/2009 - ANadir comprobaciones de garantías.
                  IF num_err = 0 THEN
                     IF gpro_reg.ctipcap = 1 THEN
                        --capital fijo
                        -- Bug 21656 - APD - 15/03/2012 - debe coger el capital revalorizado
                        -- no el que tenia inicialmente en garanrpro si es un suplemento
                        --vicapital := gpro_reg.icapmax;
                        IF NVL(c.icapital, 0) = 0 THEN
                           vicapital := NVL(gpro_reg.icapmax, c.icapital);
                        ELSE
                           vicapital := NVL(c.icapital, gpro_reg.icapmax);
                        END IF;

                        -- fin Bug 21656 - APD - 15/03/2012
                        v_modif_capital := TRUE;
                     -- Ini Bug 21707 - 20/03/2012 - MDS
                     ELSIF gpro_reg.ctipcap = 2 THEN
                        IF NVL(c.icapital, 0) = 0 THEN
                           vicapital :=
                              NVL
                                 (pac_parametros.f_pargaranpro_n
                                              (psproduc,
                                               pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                            pnriesgo, 'EST'),
                                               c.cgarant, 'VALORDEFCAPITALGARAN'),
                                  c.icapital);
                        ELSE
                           vicapital :=
                              NVL
                                 (c.icapital,
                                  pac_parametros.f_pargaranpro_n
                                              (psproduc,
                                               pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                            pnriesgo, 'EST'),
                                               c.cgarant, 'VALORDEFCAPITALGARAN'));
                        END IF;

                        v_modif_capital := TRUE;
                     -- fin Bug 21707 - 20/03/2012 - MDS
                     ELSE
                        -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                        num_err :=
                           f_valida_dependencias_k
                                              (paccion, psseguro, pnriesgo, pnmovimi,
                                               c.cgarant, psproduc,
                                               pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                            pnriesgo, 'EST'),
                                               c.nmovima);
                        -- Bug 9699 - APD - 23/04/2009 - fin
                     --capturamos el error pero se utiliza más tarde;
                     END IF;

                     IF gpro_reg.ctipcap = 4 THEN
                        vicapital := 0;
                        v_modif_capital := TRUE;
                     END IF;

                     -- Bug 11735 - RSC - 27/01/2010 - APR - suplemento de modificación de capital /prima
                     SELECT COUNT(*)
                       INTO v_tariff
                       FROM estdetgaranseg
                      WHERE sseguro = psseguro
                        AND nmovimi = pnmovimi
                        AND nriesgo = pnriesgo
                        AND cgarant = c.cgarant
                        AND cunica NOT IN(2);

                     IF (NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) NOT IN(1, 2)
                         OR(NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN(1, 2)
                            AND v_tariff > 0)) THEN
                        -- Fin Bug 11735
                        IF gpro_reg.ctipcap = 5 THEN
                           -- BUG9496:17/03/2009:DRA:Inici
                           vicapital := 0;
                           /***** BUG25037:DRA:14/12/2012: Esto no se ejecutará nunca por el IF *****
                           IF ff_calcula_capital(psproduc, pcactivi, c.cgarant) = 1 THEN
                              num_err2 := f_calculo_capital_calculado(c.finiefe, psseguro,
                                                                      pcactivi, c.cgarant,
                                                                      pnriesgo, pnmovimi, 1,
                                                                      vicapital);

                              IF num_err2 <> 0 THEN
                                 vicapital := 0;
                              END IF;
                           END IF;
                           ***************************************************************************/
                           v_modif_capital := TRUE;
                            -- BUG9496:17/03/2009:DRA:Fi
                        /*UPDATE estgaranseg
                        SET icapital = vicapital
                        WHERE sseguro = psseguro
                          AND nriesgo = pnriesgo
                          AND nmovimi = pnmovimi
                          AND cgarant = pcgarant
                          AND nmovima = pnmovima;*/
                        END IF;

                        IF v_modif_capital
                           AND NOT isaltacol THEN
                           UPDATE estgaranseg
                              SET icapital = vicapital
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi = pnmovimi
                              AND cgarant = pcgarant
                              AND nmovima = pnmovima;
                        END IF;
                     -- Bug 11735 - RSC - 27/01/2010 - APR - suplemento de modificación de capital /prima
                     END IF;

                     -- Fin Bug 11735
                     IF num_err = 0 THEN
                        -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
                        -- Bug 21786 - APD - 22/03/2012 - se le estaba pasando cgarant en vez del sproduc
                        -- al llamar a la funcion f_validar_capital_max_depen
                        num_err :=
                           f_validar_capital_max_depen
                                              (vicapital, psseguro, pnriesgo, pnmovimi,
                                               c.cgarant, psproduc,
                                               pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                            pnriesgo, 'EST'),
                                               c.nmovima);
                     -- fin Bug 21786 - APD - 22/03/2012
                     -- Bug 9699 - APD - 23/04/2009 - fin
                     END IF;

                     IF gpro_reg.ctipcap = 7 THEN
                        -- Bug 26923/148534 - APD - 08/07/2013 - se le pasan los parametros a la funcion
                        num_err := f_cargar_lista_valores('EST', psseguro, pnriesgo, pnmovimi,
                                                          c.cgarant, c.nmovima, vicapital);
                     -- fin Bug 26923/148534 - APD - 08/07/2013
                     END IF;

                     IF gpro_reg.cdtocom = 1
                        AND c.pdtocom IS NULL THEN
                        vpdtocom := seg_reg.pdtocom;
                     END IF;

                     -- BUG9598:DRA:12/05/2009:Inici
                     FOR r_garcap IN garantias_hijas_capital(psproduc, pcgarant) LOOP
                        num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi,
                                                        r_garcap.cgarant, paccion, psproduc,
                                                        pcactivi, pmensa, r_garcap.nmovima);

                        IF num_err <> 0 THEN
                           RAISE ex_update;
                        END IF;
                     END LOOP;
                  -- BUG9598:DRA:12/05/2009:Fi

                  -- Ini bug 18345 - SRA - 03/05/2011: aNadimos llamada a la función que recupera las validaciones que se han
                     -- definido para la combinación de garantía/producto/actividad
                     /*
                     num_err := f_valida_garanproval(c.cgarant, psseguro, pnriesgo, pnmovimi,
                                                     psproduc, pcactivi, pmensa, 'PRE');

                     IF num_err <> 0 THEN
                        RAISE ex_update;
                     END IF;
                     */
                  -- Fin bug 18345 - SRA - 03/05/2011
                  END IF;
               ELSE
                  vcobliga := 0;
                  RAISE ex_update;
               END IF;
            ELSE
               RAISE ex_update;
            END IF;
         ELSE   --des-seleccionamos
            vicapital_bck := c.icapital;
            vicapital := NULL;
            -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
            num_err := f_valida_dependencias(paccion, psproduc, seg_reg.cramo,
                                             seg_reg.cmodali, seg_reg.ctipseg,
                                             seg_reg.ccolect,
                                             pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                          pnriesgo, 'EST'),
                                             psseguro, pnriesgo, pnmovimi, c.cgarant, pmensa,
                                             c.nmovima);

            -- Bug 9699 - APD - 23/04/2009 - fin
            IF num_err = 0 THEN   --valida dependencias
               IF gpro_reg.ctipcap = 7 THEN
                  -- Bug 26923/148534 - APD - 08/07/2013 -
                  --num_err := f_borra_lista;
                  vicapital := NULL;
               -- fin Bug 26923/148534 - APD - 08/07/2013
               END IF;

               IF gpro_reg.ctipcap = 5 THEN
                  vicapital := NULL;
               END IF;

               -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
               num_err := f_marcar_dep_obliga(paccion, psproduc,
                                              pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                           pnriesgo, 'EST'),
                                              c.cgarant, psseguro, pnriesgo, pnmovimi, pmensa,
                                              c.nmovima);
               -- Bug 9699 - APD - 23/04/2009 - fin

               --Bug.: 18350 - ICV - 01/05/2011
               -- Bug 21786 - APD - 27/03/2012 -- se comenta el IF
               --IF c.ctipgar NOT IN(5, 6) THEN
               -- fin Bug 21786 - APD - 27/03/2012
               num_err :=
                  pk_nueva_produccion.f_marcar_dep_multiples
                                               (paccion, psproduc,
                                                pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                             pnriesgo, 'EST'),
                                                c.cgarant, psseguro, pnriesgo, pnmovimi,
                                                pmensa, c.nmovima);

               IF num_err <> 0 THEN
                  RAISE ex_update;
               END IF;

               -- Bug 21786 - APD - 27/03/2012 - se modifica el ELSIF
               --ELSIF c.ctipgar = 6 THEN
               IF c.ctipgar = 6 THEN
                  -- fin Bug 21786 - APD - 27/03/2012
                  v_retorno :=
                     pk_nueva_produccion.f_cumpleix_dep_multiple
                                              (psproduc,
                                               pac_seguros.ff_get_actividad(seg_reg.sseguro,
                                                                            pnriesgo, 'EST'),
                                               c.cgarant, psseguro, pnriesgo, pnmovimi,
                                               pmensa, c.nmovima);

                  -- Si v_retorno = 1 es que la garantía cumple dependencia y debe quedarse marcada
                  IF v_retorno = 1 THEN
                     vcobliga := 1;
                     vicapital := NVL(c.icapital, 0);
                     --pmensa := f_axis_literales
                     --pmensa := f_axis_literales(9901996, pac_md_common.f_get_cxtidioma());

                     --num_err := 0;
                     num_err := 9901996;
                     RAISE ex_update;   --No se puede desmarcar
                  END IF;
               END IF;

               --Fi bug.: 18350
               vicapital := NULL;
               viprianu := NULL;
               vprecarg := NULL;
               vpdtocom := NULL;
               viextrap := NULL;
               RAISE ex_update;
            ELSE
               vicapital := vicapital_bck;
               RAISE ex_update;
            END IF;
         END IF;   --cobliga =1
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN ex_update THEN
         UPDATE estgaranseg
            SET cobliga = vcobliga,
                icapital = vicapital,
                pdtocom = vpdtocom
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = pcgarant
            AND nmovima = pnmovima;

         COMMIT;
         RETURN num_err;
   END f_validacion_cobliga;

   FUNCTION f_valida_incompatibles(
      pcgarant IN NUMBER,
      pcobliga IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER IS
      CURSOR otras_gar IS
         SELECT cgarant, cobliga
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant <> pcgarant
            AND cobliga = 1;

      aux_garan      incompgaran.cgarant%TYPE;
      -- BUG 26550 - FAL - 09/04/2013
      vsproduc       productos.sproduc%TYPE;
      vnpoliza       estseguros.npoliza%TYPE;
      vsseguro       estseguros.sseguro%TYPE;
      v_existe       NUMBER;
      v_escertif0    NUMBER;
   -- FI BUG 26550
   BEGIN
      p_define_modo('EST');   -- BUG14652:DRA:27/05/2010

      -- BUG 26550 - FAL - 09/04/2013. No validar garantias excluyentes para colectivos con parprod 'EVAL_INCOMP_GAR' = 1
      BEGIN
         SELECT npoliza, ssegpol, sproduc
           INTO vnpoliza, vsseguro, vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         isaltacol := FALSE;

         IF NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, vsseguro);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe <= 0 THEN
                  isaltacol := TRUE;
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            isaltacol := FALSE;
      END;

      IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'EVAL_INCOMP_GAR'), 0) = 1
         AND isaltacol THEN
         RETURN 0;
      END IF;

      -- FI BUG 26550 - FAL - 4/4/2013
      IF pcobliga = 1 THEN
         pmensa := NULL;

         FOR c IN otras_gar LOOP
            DECLARE
               v_cactivi      garanpro.cactivi%TYPE;
            BEGIN
               --BUG9748 - 09/04/2009 - JTS - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
               SELECT DECODE(COUNT(*), 0, 0, pcactivi)
                 INTO v_cactivi
                 FROM garanpro
                WHERE cramo = pcramo
                  AND ccolect = pccolect
                  AND cmodali = pcmodali
                  AND cgarant = pcgarant
                  AND cactivi = pcactivi;

               --Fi BUG9748
               SELECT cgarant
                 INTO aux_garan
                 FROM incompgaran
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = v_cactivi
                  AND cgarant = c.cgarant
                  AND cgarinc = pcgarant;

               -- BUG14652:DRA:27/05/2010:Inici
               -- pmensa := ' (' || c.cgarant || ' - ' || pcgarant || ' )';
               pmensa := ' (' || aux_f_desgarantia(c.cgarant) || ' - '
                         || aux_f_desgarantia(pcgarant) || ' )';
               -- BUG14652:DRA:27/05/2010:Fi
               RETURN 100791;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END LOOP;
      END IF;

      RETURN 0;
   END f_valida_incompatibles;

   FUNCTION f_marcar_dep_obliga(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER)
      RETURN NUMBER IS
      -- Bug 21786 - APD - 26/03/2012
      -- se aNade el parametro al cursor
      CURSOR garantias(pctipgar NUMBER) IS
         -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgardep = pcgarant
            AND cactivi = pcactivi
            AND ctipgar = pctipgar   --4
         UNION
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgardep = pcgarant
            AND cactivi = 0
            AND ctipgar = pctipgar   --4
            AND NOT EXISTS(SELECT cgarant
                             FROM garanpro
                            WHERE sproduc = psproduc
                              AND cgardep = pcgarant
                              AND cactivi = pcactivi
                              AND ctipgar = pctipgar /*4*/);

      -- fin Bug 21786 - APD - 26/03/2012
      -- Bug 9699 - APD - 23/04/2009 - Fin
      num_err        NUMBER;

      -- Bug 21786 - APD - 28/03/2012 - funcion para saber si la garantia padre,
      -- garantia de la cual depende, está seleccionada o no
      FUNCTION ff_cobliga
         RETURN NUMBER IS
         vcobliga       estgaranseg.cobliga%TYPE;
      BEGIN
         SELECT cobliga
           INTO vcobliga
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND ffinefe IS NULL;

         RETURN vcobliga;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
      END ff_cobliga;
   -- fin Bug 21786 - APD - 28/03/2012
   BEGIN
      -- Bug 21786 - APD - 26/03/2012
      -- v.f. 33 4.-Dependiente obligatoria
      FOR c IN garantias(4) LOOP
         IF paccion = 'SEL'
            AND f_valida_exclugarseg('EST', psseguro, pnriesgo, pcgarant) = 0 THEN
            -- Bug 21786 - APD - 28/03/2012 - se aNade el IF
            -- si su padre, garantia de la cual depende, está seleccionda tambien
            -- se puede seleccionar la garantia dependiente
            IF ff_cobliga = 1 THEN
               UPDATE estgaranseg
                  SET cobliga = 1
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND cgarant = c.cgarant;
            END IF;
         -- fin Bug 21786 - APD - 28/03/2012 - se aNade el IF
         ELSE
            -- Bug 21786 - APD - 28/03/2012 - se aNade el IF
            -- si su padre, garantia de la cual depende, NO está seleccionda
            -- se puede desseleccionar la garantia dependiente
            IF ff_cobliga = 0 THEN
               UPDATE estgaranseg
                  SET cobliga = 0
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND cgarant = c.cgarant;
            END IF;
         -- fin Bug 21786 - APD - 28/03/2012 - se aNade el IF
         END IF;

         num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, paccion,
                                         psproduc, pcactivi, pmensa, pnmovima);
      END LOOP;

      -- fin Bug 21786 - APD - 26/03/2012

      -- Bug 21786 - APD - 26/03/2012
      -- v.f. 33 3.-Dependiente opcional
      -- si se está deseleccionando una garantia se debe deseleccionar también
      -- sus garantias dependientes opcionales
      IF paccion = 'DESEL' THEN
         FOR c IN garantias(3) LOOP
            -- Bug 21786 - APD - 28/03/2012 - se aNade el IF
            -- si su padre, garantia de la cual depende, NO está seleccionda
            -- se puede desseleccionar la garantia dependiente
            IF ff_cobliga = 0 THEN
               UPDATE estgaranseg
                  SET cobliga = 0
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND nriesgo = pnriesgo
                  AND cgarant = c.cgarant;
            END IF;

            -- fin Bug 21786 - APD - 28/03/2012 - se aNade el IF
            num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, paccion,
                                            psproduc, pcactivi, pmensa, pnmovima);
         END LOOP;
      END IF;

      -- fin Bug 21786 - APD - 26/03/2012
      COMMIT;
      -- hay que hacer la validación de incompatibles.
      RETURN 0;
   END f_marcar_dep_obliga;

   FUNCTION f_valida_dependencias(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      garpro         garanpro%ROWTYPE;
      estgar         estgaranseg%ROWTYPE;
      vcobliga       estgaranseg.cobliga%TYPE := 0;
      ex_update      EXCEPTION;
      vtrotgar       VARCHAR2(2000);
      -- Bug 11735 - RSC - 15/01/2010 - APR - suplemento de modificación de capital /prima
      v_conta_pol    NUMBER;
      v_csituac_pol  NUMBER;
   -- Fin Bug 11735
   BEGIN
      p_define_modo('EST');   -- BUG14652:DRA:27/05/2010
      num_err := f_valida_obligatorias(paccion, psproduc, pcramo, pcmodali, pctipseg,
                                       pccolect, pcactivi, psseguro, pnriesgo, pnmovimi,
                                       pcgarant, pmensa, pnmovima);

      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      SELECT *
        INTO estgar
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo
         AND nmovima = pnmovima
         AND cgarant = pcgarant;

      IF paccion = 'SEL'
         AND num_err = 0 THEN
         IF garpro.cgardep IS NOT NULL THEN
            -- Bug 11735 - RSC - 15/01/2010 - APR - suplemento de modificación de capital /prima
            SELECT COUNT(1)
              INTO v_conta_pol
              FROM seguros s, estseguros es
             WHERE s.sseguro = es.ssegpol
               AND es.sseguro = psseguro;

            IF v_conta_pol > 0 THEN
               SELECT es.csituac
                 INTO v_csituac_pol
                 FROM seguros s, estseguros es
                WHERE s.sseguro = es.ssegpol
                  AND es.sseguro = psseguro;
            END IF;

            -- Fin Bug 11735
            SELECT NVL(cobliga, 0)
              INTO vcobliga
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               -- AND nmovima = pnmovima
               AND cgarant = garpro.cgardep;

            -- Bug 11735 - RSC - 15/01/2010 - APR - suplemento de modificación de capital /prima
            IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
               IF (v_conta_pol <= 0)   -- Nueva emisión
                  OR(v_conta_pol > 0
                     AND v_csituac_pol IN(4))   -- Emisión de propuesta retenida
                  OR(v_conta_pol > 0
                     AND v_csituac_pol IN(5)
                     AND NVL(f_pargaranpro_v(pcramo, pcmodali, pctipseg, pccolect, pcactivi,
                                             garpro.cgardep, 'TIPO'),
                             0) NOT IN(3, 4)) THEN
                  -- Fin Bug 11735
                  IF vcobliga = 0 THEN
                     num_err := 108388;

                     --BUG8916-06/02/2009-XVILA: s'afegeix el ròtul de la garantia
                     BEGIN
                        SELECT trotgar
                          INTO vtrotgar
                          FROM garangen
                         WHERE cidioma = NVL(f_usu_idioma, 1)
                           AND cgarant = garpro.cgardep;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           vtrotgar := NULL;
                     END;

                     pmensa := vtrotgar;
                     --BUG8916-06/02/2009-XVILA: s'afegeix el ròtul de la garantia
                     RAISE ex_update;
                  END IF;
               END IF;
            ELSE
               IF vcobliga = 0 THEN
                  num_err := 108388;

                  --BUG8916-06/02/2009-XVILA: s'afegeix el ròtul de la garantia
                  BEGIN
                     SELECT trotgar
                       INTO vtrotgar
                       FROM garangen
                      WHERE cidioma = NVL(f_usu_idioma, 1)
                        AND cgarant = garpro.cgardep;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vtrotgar := NULL;
                  END;

                  pmensa := vtrotgar;
                  --BUG8916-06/02/2009-XVILA: s'afegeix el ròtul de la garantia
                  RAISE ex_update;
               END IF;
            END IF;
         END IF;
      ELSIF paccion = 'DESEL'
            AND num_err = 0 THEN
         IF estgar.ctipgar = 4 THEN
            SELECT NVL(cobliga, 0)
              INTO vcobliga
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               --    AND nmovima = pnmovima
               AND cgarant = garpro.cgardep;

            IF vcobliga = 1 THEN
               num_err := 108389;
               -- BUG14652:DRA:27/05/2010:Inici
               -- pmensa := garpro.cgardep;
               pmensa := aux_f_desgarantia(garpro.cgardep);
               -- BUG14652:DRA:27/05/2010:Fi
               RAISE ex_update;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN ex_update THEN
         UPDATE estgaranseg
            SET cobliga = vcobliga
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = pcgarant;

         RETURN num_err;
   END f_valida_dependencias;

/**********************************************************************************/
   FUNCTION f_valida_obligatorias(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      --
      CURSOR garantias_hijas(pcpargar IN VARCHAR2, pcvalpar IN NUMBER) IS
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = pcactivi
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
         UNION
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = 0
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
              AND NOT EXISTS(SELECT cgarant
                               FROM pargaranpro
                              WHERE cmodali = pcmodali
                                AND cramo = pcramo
                                AND ctipseg = pctipseg
                                AND ccolect = pccolect
                                AND cactivi = pcactivi
                                AND cpargar = pcpargar
                                AND cvalpar = pcvalpar)
         ORDER BY cgarant;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      CURSOR garantias_hijas_obli(psproduc IN NUMBER, pcgarant IN NUMBER) IS
         SELECT DISTINCT (g.cgarant) cgarant, g.ctipgar ctipgar, g.cpardep cpardep,
                         g.cvalpar cvalpar
                    FROM garanpro g, pargaranpro pg
                   WHERE g.cramo = pg.cramo
                     AND g.cmodali = pg.cmodali
                     AND g.ctipseg = pg.ctipseg
                     AND g.ccolect = pg.ccolect
                     AND g.cactivi = pg.cactivi
                     AND g.cpardep = pg.cpargar
                     AND g.cvalpar = pg.cvalpar
                     AND g.sproduc = psproduc
                     AND pg.cgarant = pcgarant;

      CURSOR garantias_padres(pcpargar IN VARCHAR2, pcvalpar IN NUMBER) IS
         -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a PARGARANPRO para la actividad cero
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = pcactivi
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
         UNION
         SELECT   cgarant
             FROM pargaranpro
            WHERE cmodali = pcmodali
              AND cramo = pcramo
              AND ctipseg = pctipseg
              AND ccolect = pccolect
              AND cactivi = 0
              AND cpargar = pcpargar
              AND cvalpar = pcvalpar
              AND NOT EXISTS(SELECT cgarant
                               FROM pargaranpro
                              WHERE cmodali = pcmodali
                                AND cramo = pcramo
                                AND ctipseg = pctipseg
                                AND ccolect = pccolect
                                AND cactivi = pcactivi
                                AND cpargar = pcpargar
                                AND cvalpar = pcvalpar)
         ORDER BY cgarant;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      CURSOR garantias_marcadas IS
         SELECT cgarant, cobliga, sseguro, nriesgo, nmovimi, nmovima
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nmovima = pnmovima
            AND nriesgo = pnriesgo
            AND cobliga = 1;

      estgar         estgaranseg%ROWTYPE;
      garpro         garanpro%ROWTYPE;
      salir          BOOLEAN := FALSE;
      num_err        NUMBER := 0;
      ex_update      EXCEPTION;
      v_cobliga      estgaranseg.cobliga%TYPE;
   BEGIN
      p_define_modo('EST');   -- BUG14652:DRA:27/05/2010

      SELECT *
        INTO estgar
        FROM estgaranseg
       WHERE cgarant = pcgarant
         AND sseguro = psseguro
         AND nmovimi = pnmovimi
         AND nmovima = pnmovima
         AND nriesgo = pnriesgo;

      --  and nvl(ctarman,0) = 0;

      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      v_cobliga := estgar.cobliga;

      IF paccion = 'SEL'
         AND estgar.cobliga = 1 THEN
         IF estgar.ctipgar IN(5, 6) THEN
            -- Bug 21786 - APD - 23/03/2012 - se aNade el if garpro.cpardep
            -- para que no se ejecute IF NOT salir THEN si no ha entrado
            -- en el bucle
            IF garpro.cpardep IS NOT NULL THEN
               FOR c IN garantias_hijas(garpro.cpardep, garpro.cvalpar) LOOP
                  --Miramos si todas las garantias padre estan seleccionadas
                  FOR g IN garantias_marcadas LOOP
                     IF c.cgarant = g.cgarant THEN
                        salir := TRUE;
                     END IF;
                  END LOOP;

                  IF salir THEN
                     EXIT;   --salimos porque ya hemos encontrado una
                  END IF;
               END LOOP;

               IF NOT salir THEN
                  num_err := 108388;
                  --Falta seleccionar alguna garantia de la cual depende
                  v_cobliga := 0;
                  RAISE ex_update;
               END IF;
            END IF;
         -- fin Bug 21786 - APD - 23/03/2012
         ELSE
            --Miramos si es padre de una garantia obligatoria
            FOR c IN garantias_hijas_obli(psproduc, pcgarant) LOOP
               IF c.ctipgar = 6 THEN
                  FOR g IN garantias_marcadas LOOP
                     num_err := f_validacion_cobliga(g.sseguro, g.nriesgo, g.nmovimi,
                                                     g.cgarant, 'SEL', psproduc, pcactivi,
                                                     pmensa, g.nmovima);

                     IF num_err <> 0 THEN
                        RAISE ex_update;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      ELSE   --deseleccion
         IF estgar.ctipgar = 6 THEN
            FOR c IN garantias_hijas(garpro.cpardep, garpro.cvalpar) LOOP
               --Miramos las garantias padres si están deseleccionadas
               FOR g IN garantias_marcadas LOOP
                  IF c.cgarant = g.cgarant THEN
                     num_err := 108389;
                     -- BUG14652:DRA:27/05/2010:Inici
                     -- pmensa := g.cgarant;
                     pmensa := aux_f_desgarantia(g.cgarant);
                     -- BUG14652:DRA:27/05/2010:Fi
                     v_cobliga := 0;
                     RAISE ex_update;
                  END IF;
               END LOOP;
            END LOOP;
         ELSE
            FOR c IN garantias_hijas_obli(psproduc, pcgarant) LOOP
               IF c.ctipgar IN(5, 6) THEN
                  FOR g IN garantias_padres(c.cpardep, c.cvalpar) LOOP
                     FOR h IN garantias_marcadas LOOP
                        UPDATE estgaranseg
                           SET cobliga = 1
                         WHERE sseguro = h.sseguro
                           AND nriesgo = h.nriesgo
                           AND nmovimi = h.nmovimi
                           AND nmovima = h.nmovima
                           AND cgarant = h.cgarant;

                        num_err := f_validacion_cobliga(h.sseguro, h.nriesgo, h.nmovimi,
                                                        h.cgarant, 'SEL', psproduc, pcactivi,
                                                        pmensa, h.nmovima);

                        IF num_err <> 0 THEN
                           RAISE ex_update;
                        END IF;
                     END LOOP;
                  END LOOP;

                  FOR h IN garantias_marcadas LOOP
                     IF c.cgarant = h.cgarant THEN
                        UPDATE estgaranseg
                           SET cobliga = 0
                         WHERE sseguro = h.sseguro
                           AND nriesgo = h.nriesgo
                           AND nmovimi = h.nmovimi
                           AND nmovima = h.nmovima
                           AND cgarant = h.cgarant;

                        num_err := f_validacion_cobliga(h.sseguro, h.nriesgo, h.nmovimi,
                                                        h.cgarant, 'DESEL', psproduc, pcactivi,
                                                        pmensa, h.nmovima);

                        IF num_err <> 0 THEN
                           RAISE ex_update;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN ex_update THEN
         UPDATE estgaranseg
            SET cobliga = v_cobliga
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = pcgarant;

         RETURN num_err;
   END f_valida_obligatorias;

   FUNCTION f_validar_edad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vfefecto       DATE;
      vsperson       estriesgos.sperson%TYPE;
      vnedamic       garanpro.nedamic%TYPE;
      vnedamac       garanpro.nedamac%TYPE;
      vciedmic       garanpro.ciedmic%TYPE;
      vciedmac       garanpro.ciedmac%TYPE;
      vnsedmac       NUMBER;
      vcobjase       productos.cobjase%TYPE;
      num_err        NUMBER;
      -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
      v_cresp4044    pregunpolseg.trespue%TYPE;
      v_ssegpol      estseguros.ssegpol%TYPE;
      v_fecha_edad   DATE;
      v_dummy        NUMBER;
      v_existe       NUMBER;
      -- Fin bug 19715

      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0
      vnpoliza       estseguros.npoliza%TYPE;
      -- Fin bug 22839

      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0
      vncertif       estseguros.ncertif%TYPE;
      -- Fin Bug 22839
      v_escertif0    NUMBER;
      vsseguro       estseguros.ssegpol%TYPE;
      vcduraci       estseguros.cduraci%TYPE;
      vndurcob       estseguros.ndurcob%TYPE;
      vnedamar       estseguros.nedamar%TYPE;
      vnedamacprd    productos.nedamac%TYPE;
      vnedamacgar    edadrenova_permite.nedamacgar%TYPE;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      BEGIN
         SELECT g.nedamic, g.nedamac, g.ciedmic, g.ciedmac, p.cobjase, p.nedamac
           INTO vnedamic, vnedamac, vciedmic, vciedmac, vcobjase, vnedamacprd
           FROM garanpro g, productos p
          WHERE g.sproduc = psproduc
            AND g.cactivi = pcactivi
            AND g.cgarant = pcgarant
            AND g.sproduc = p.sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT g.nedamic, g.nedamac, g.ciedmic, g.ciedmac, p.cobjase, p.nedamac
              INTO vnedamic, vnedamac, vciedmic, vciedmac, vcobjase, vnedamacprd
              FROM garanpro g, productos p
             WHERE g.sproduc = psproduc
               AND g.cactivi = 0
               AND g.cgarant = pcgarant
               AND g.sproduc = p.sproduc;
      END;

     -- Asteriscado el if  ALTACERO_DESCRIPCION' Pq si no es una descripción y es colectivo y alta es del certif 0 no tiene que validar Edades del Riesgo
      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0
--   IF NVL(pac_parametros.f_parproducto_n(psproduc, 'ALTACERO_DESCRIPCION'), 0) = 1 THEN
      BEGIN
         SELECT npoliza, ncertif, ssegpol
           INTO vnpoliza, vncertif, vsseguro
           FROM estseguros
          WHERE sseguro = psseguro;

         isaltacol := FALSE;

         IF NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, vsseguro);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe <= 0 THEN
                  isaltacol := TRUE;
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            isaltacol := FALSE;
      END;

      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0 (aNadimos certificado)
      IF (isaltacol
          OR(NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
             AND vncertif = 0)) THEN
         vcobjase := 3;
      END IF;

--    END IF;

      -- Fin bug 22839
      -- Bug 9699 - APD - 23/04/2009 - Fin
      IF vcobjase = 1 THEN
         SELECT r.sperson, s.fefecto, s.ssegpol, s.cduraci, s.ndurcob,
                s.nedamar   -- Bug 0025584 - MMS - 28/02/2013 - : POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto
           INTO vsperson, vfefecto, v_ssegpol, vcduraci, vndurcob,
                vnedamar   -- Bug 0025584 - MMS - 28/02/2013 - : POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto
           FROM estriesgos r, estseguros s
          WHERE r.sseguro = psseguro
            AND r.nriesgo = pnriesgo
            AND r.sseguro = s.sseguro;

         -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
         SELECT COUNT(*)
           INTO v_existe
           FROM seguros
          WHERE sseguro = v_ssegpol;

         -- Fin Bug 19715

         -- Bug 0025584 - MMS - 28/02/2013 - : POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto
         IF vcduraci = 7 THEN
		 -- Inicio Bug 41043 Prod. - ACL 17/03/2016 POSES100-POS-TEC ERROR AL TARIFAR EN PRODUCTO LARGO PLAZO INV
           IF psproduc = 7061  THEN
			        IF vnedamar = 60 THEN
                    vnedamacgar := 60;
				      ELSIF vnedamar = 65 THEN
				    vnedamacgar := 65;
		         END IF;
		 -- Fin Bug 41043 Prod. - ACL
		   ELSE
            BEGIN
               SELECT nedamacgar
                 INTO vnedamacgar
                 FROM edadrenova_permite
                WHERE sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND nedamarprd = vnedamar;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT nedamacgar
                       INTO vnedamacgar
                       FROM edadrenova_permite
                      WHERE sproduc = psproduc
                        AND cactivi = 0
                        AND cgarant = pcgarant
                        AND nedamarprd = vnedamar;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnedamacgar := NULL;
                  END;
            END;
           END IF;
            vnedamac := NVL(vnedamacgar, NVL(vnedamac, vnedamacprd)) - NVL(vndurcob, 0);
         END IF;

         -- Fin Bug 0025584 - MMS - 28/02/2013

         -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
         -- Aqui ya tenemos las preguntas grabadas en las EST.
         -- Bug 25584 - FPG - 07-02-2013 - inicio
         IF NVL(pac_parametros.f_parproducto_n(psproduc, 'VALIDA_EDAD_ASEG_PRO'), 1) = 0 THEN
            --IF NVL(pac_parametros.f_parproducto_n(psproduc, 'VALIDA_EDAD_ASEG_PRO'), 1) = 1 THEN
               -- Bug 25584 - FPG - 07-02-2013 - final
            num_err := pac_preguntas.f_get_pregunpolseg_t(psseguro, 4044, 'EST', v_cresp4044);

            IF num_err > 0 THEN
               IF num_err <> 120135 THEN
                  RETURN num_err;
               END IF;
            END IF;

            IF v_existe > 0 THEN
               BEGIN
                  SELECT 1
                    INTO v_dummy
                    FROM seguros s, garanseg g
                   WHERE s.sseguro = v_ssegpol
                     AND g.sseguro = s.sseguro
                     AND g.nriesgo = pnriesgo
                     AND g.ffinefe IS NULL
                     AND g.cgarant = pcgarant;

                  v_fecha_edad := NVL(TO_DATE(v_cresp4044, 'DD/MM/YYYY'), vfefecto);
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT finiefe
                          INTO v_fecha_edad
                          FROM estseguros s, estgaranseg g
                         WHERE s.sseguro = psseguro
                           AND g.sseguro = s.sseguro
                           AND g.nriesgo = pnriesgo
                           AND g.ffinefe IS NULL
                           AND g.cgarant = pcgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           -- No validem la edat perque la garantia encara no esta contractada
                           RETURN 0;
                     END;
               END;
            ELSE
               v_fecha_edad := NVL(TO_DATE(v_cresp4044, 'DD/MM/YYYY'), vfefecto);
            END IF;

            num_err := f_control_edat(vsperson, v_fecha_edad, NVL(vnedamic, 0),
                                      NVL(vciedmic, 0), NVL(vnedamac, 999), NVL(vciedmac, 0),
                                      NULL, NULL, NULL, 1);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         ELSE
            -- Fin Bug 19715

            -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
            IF v_existe > 0 THEN
               BEGIN
                  SELECT 1
                    INTO v_dummy
                    FROM seguros s, garanseg g
                   WHERE s.sseguro = v_ssegpol
                     AND g.sseguro = s.sseguro
                     AND g.nriesgo = pnriesgo
                     AND g.ffinefe IS NULL
                     AND g.cgarant = pcgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- Estamos dando de alta la garantía
                     BEGIN
                        SELECT finiefe
                          INTO vfefecto
                          FROM estseguros s, estgaranseg g
                         WHERE s.sseguro = psseguro
                           AND g.sseguro = s.sseguro
                           AND g.nriesgo = pnriesgo
                           AND g.ffinefe IS NULL
                           AND g.cgarant = pcgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           -- No validem la edat perque la garantia encara no esta contractada
                           RETURN 0;
                     END;
               END;
            END IF;

            -- Fin Bug 19715
            num_err := f_control_edat(vsperson, vfefecto, NVL(vnedamic, 0), NVL(vciedmic, 0),
                                      NVL(vnedamac, 999), NVL(vciedmac, 0), NULL, NULL, NULL,
                                      1);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         /*********** falta las validaciones de 2 cabeza **************/

         -- Bug 19715 - RSC - 13/01/2012 - LCOL: Migración de productos de Vida Individual
         END IF;
      -- Fin bug 19715
      END IF;

      RETURN 0;
   END f_validar_edad;

   FUNCTION f_validar_edad_seg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vfefecto       DATE;
      vsperson       riesgos.sperson%TYPE;
      vnedamic       garanpro.nedamic%TYPE;
      vnedamac       garanpro.nedamac%TYPE;
      vciedmic       garanpro.ciedmic%TYPE;
      vciedmac       garanpro.ciedmac%TYPE;
      vnsedmac       NUMBER;
      vcobjase       productos.cobjase%TYPE;
      num_err        NUMBER;
      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0
      vnpoliza       estseguros.npoliza%TYPE;
      v_existe       NUMBER;
      -- Fin Bug 22839
      v_escertif0    NUMBER;
      vsseguro       NUMBER;
      vcduraci       estseguros.cduraci%TYPE;
      vndurcob       estseguros.ndurcob%TYPE;
      vnedamar       estseguros.nedamar%TYPE;
      vnedamacprd    productos.nedamac%TYPE;
      vnedamacgar    edadrenova_permite.nedamacgar%TYPE;
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT g.nedamic, g.nedamac, g.ciedmic, g.ciedmac, p.cobjase, p.nedamac
           INTO vnedamic, vnedamac, vciedmic, vciedmac, vcobjase, vnedamacprd
           FROM garanpro g, productos p
          WHERE g.sproduc = psproduc
            AND g.cactivi = pcactivi
            AND g.cgarant = pcgarant
            AND g.sproduc = p.sproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT g.nedamic, g.nedamac, g.ciedmic, g.ciedmac, p.cobjase, p.nedamac
              INTO vnedamic, vnedamac, vciedmic, vciedmac, vcobjase, vnedamacprd
              FROM garanpro g, productos p
             WHERE g.sproduc = psproduc
               AND g.cactivi = 0
               AND g.cgarant = pcgarant
               AND g.sproduc = p.sproduc;
      END;

     -- Asteriscado el if  ALTACERO_DESCRIPCION' Pq si no es una descripción y es colectivo y alta es del certif 0 no tiene que validar Edades del Riesgo
      -- Bug 22839 - RSC - 18/07/2012 - LCOL - Funcionalidad Certificado 0
--   IF NVL(pac_parametros.f_parproducto_n(psproduc, 'ALTACERO_DESCRIPCION'), 0) = 1 THEN
      BEGIN
         SELECT npoliza, ssegpol
           INTO vnpoliza, vsseguro
           FROM estseguros
          WHERE sseguro = psseguro;

         isaltacol := FALSE;

         IF NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, vsseguro);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe <= 0 THEN
                  isaltacol := TRUE;
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            isaltacol := FALSE;
      END;

      IF pk_nueva_produccion.isaltacol THEN
         vcobjase := 3;
      END IF;

--    END IF;

      -- Fin bug 22839

      -- Bug 9699 - APD - 23/04/2009 - Fin
      IF vcobjase = 1 THEN
         SELECT r.sperson, s.fefecto, s.cduraci, s.ndurcob,
                s.nedamar   -- Bug 0025584 - MMS - 28/02/2013 - : POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto
           INTO vsperson, vfefecto, vcduraci, vndurcob,
                vnedamar   -- Bug 0025584 - MMS - 28/02/2013 - : POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto
           FROM riesgos r, seguros s
          WHERE r.sseguro = psseguro
            AND r.nriesgo = pnriesgo
            AND r.sseguro = s.sseguro;

         -- Bug 0025584 - MMS - 28/02/2013 - : POSDE600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 6 - Tipo de duracion de poliza â€˜hasta edadâ€™ y edades permitidas por producto
         IF vcduraci = 7 THEN
            BEGIN
               SELECT nedamacgar
                 INTO vnedamacgar
                 FROM edadrenova_permite
                WHERE sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND nedamarprd = vnedamar;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT nedamacgar
                       INTO vnedamacgar
                       FROM edadrenova_permite
                      WHERE sproduc = psproduc
                        AND cactivi = 0
                        AND cgarant = pcgarant
                        AND nedamarprd = vnedamar;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vnedamacgar := NULL;
                  END;
            END;

            vnedamac := NVL(vnedamacgar, NVL(vnedamac, vnedamacprd)) - NVL(vndurcob, 0);
         END IF;

         -- Fin Bug 0025584 - MMS - 28/02/2013
         num_err := f_control_edat(vsperson, vfefecto, NVL(vnedamic, 0), NVL(vciedmic, 0),
                                   NVL(vnedamac, 999), NVL(vciedmac, 0), NULL, NULL, NULL);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      /*********** falta las validaciones de 2 cabeza **************/
      END IF;

      RETURN 0;
   END f_validar_edad_seg;

   FUNCTION f_validar_capital_max_depen(
      picapital IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      v_icapital     NUMBER;
      v_capmax       NUMBER;
      v_cobliga      NUMBER;
   BEGIN
      -- Bug.14322:ASN:28/04/2010.ini
      FOR i IN (SELECT *
                  FROM garanpro
                 WHERE cgardep = pcgarant
                   AND ccapmax = 2
                   AND sproduc = psproduc
                   AND cactivi = pcactivi
                UNION
                SELECT *
                  FROM garanpro
                 WHERE cgardep = pcgarant
                   AND ccapmax = 2
                   AND sproduc = psproduc
                   AND cactivi = 0
                   AND NOT EXISTS(SELECT 1
                                    FROM garanpro
                                   WHERE cgardep = pcgarant
                                     AND ccapmax = 2
                                     AND sproduc = psproduc
                                     AND cactivi = pcactivi)) LOOP
         BEGIN
            SELECT cobliga, icapital
              INTO v_cobliga, v_icapital
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cgarant = i.cgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_cobliga := 0;
         END;

         IF v_cobliga = 1 THEN
            v_capmax := picapital * NVL(i.pcapdep, 100) / 100;

            -- Bug 21786 - APD - 23/03/2012 - se modifica el orden del if
            --IF v_capmax > v_icapital THEN
            IF v_icapital > v_capmax THEN
               -- fin Bug 21786 - APD - 23/03/2012
               UPDATE estgaranseg
                  SET icapital = v_capmax
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND nmovimi = pnmovimi
                  AND cgarant = i.cgarant;
            END IF;
         END IF;
      END LOOP;

      -- Bug.14322:ASN:28/04/2010.fin
      RETURN 0;
   END f_validar_capital_max_depen;

   FUNCTION f_valida_dependencias_k(
      paccion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      garpro         garanpro%ROWTYPE;
      estgar         estgaranseg%ROWTYPE;
      capital_principal estgaranseg.icapital%TYPE;
      capital_dependiente estgaranseg.icapital%TYPE;
      capital        estgaranseg.icapital%TYPE;
      capmax         NUMBER;
      vicapmin       NUMBER;   -- Bug 0026501 - MMS - 20130416
   BEGIN
      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      SELECT *
        INTO estgar
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND nmovima = pnmovima
         AND cgarant = pcgarant;

      capital := estgar.icapital;

      IF garpro.ctipcap = 3
         AND garpro.cgardep IS NOT NULL THEN
         SELECT NVL(icapital, 0)
           INTO capital_principal
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = garpro.cgardep;

         /*si hay más de una por nmovima que hacemos*/
         capital_dependiente := capital_principal *(NVL(garpro.pcapdep, 0) / 100);
         capmax := f_capital_maximo_garantia(psproduc, pcactivi, pcgarant, psseguro, pnriesgo,
                                             pnmovimi, pnmovima);   -- Bug.14322:ASN:28/04/2010
         -- Bug 0026501 - MMS - 20130416
         vicapmin := pk_nueva_produccion.f_capital_minimo_garantia(psproduc, pcactivi,
                                                                   pcgarant, psseguro,
                                                                   pnriesgo, pnmovimi);
         capital := LEAST(GREATEST(capital_dependiente, NVL(vicapmin, 0)),   --- MMS
                          NVL(capmax, GREATEST(capital_dependiente, NVL(vicapmin, 0))));
      -- Fin Bug 0026501 - MMS - 20130416
      ELSIF garpro.ctipcap = 6
            AND garpro.cgardep IS NOT NULL THEN
         SELECT NVL(icapital, 0)
           INTO capital_principal
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = garpro.cgardep;

         -- Fi Bug 0020671 - JRH - 12/01/2012
         capital_dependiente := NVL(capital_principal, 0) *(NVL(garpro.pcapdep, 0) / 100);
         capmax := f_capital_maximo_garantia(psproduc, pcactivi, pcgarant, psseguro, pnriesgo,
                                             pnmovimi, pnmovima);   -- Bug.14322:ASN:28/04/2010

         -- BUG9216:DRA:23-02-2009:Analizamos el capital máximo i minimo
         IF NVL(estgar.icapital, 0) = 0 THEN
            capital_dependiente := NVL(capital_principal, 0) *(NVL(garpro.pcapdep, 0) / 100);

            IF (capital_dependiente > capmax)
               AND(capmax IS NOT NULL) THEN
               capital := capmax;
            ELSIF (capital_dependiente < vicapmin)   -- Bug 0026501 - MMS - 20130416
                  AND(vicapmin IS NOT NULL) THEN   -- Bug 0026501 - MMS - 20130416
               capital := vicapmin;   -- Bug 0026501 - MMS - 20130416
            ELSE
               capital := capital_dependiente;
            END IF;
         ELSE
            IF (estgar.icapital > capmax)
               AND(capmax IS NOT NULL) THEN
               capital := capmax;
            ELSIF (estgar.icapital < vicapmin)   -- Bug 0026501 - MMS - 20130416
                  AND(vicapmin IS NOT NULL) THEN   -- Bug 0026501 - MMS - 20130416
               capital := vicapmin;   -- Bug 0026501 - MMS - 20130416
            ELSE
               capital := estgar.icapital;
            --si está informado el capital, se queda igual
            END IF;
         END IF;
      END IF;

      UPDATE estgaranseg
         SET icapital = capital
       WHERE cgarant = pcgarant
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo
         AND nmovima = pnmovima
         AND sseguro = psseguro;

      RETURN 0;
   END f_valida_dependencias_k;

   -- Bug 26923/148534 - APD - 08/07/2013 - se informa la funcion
   FUNCTION f_cargar_lista_valores(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      vcont          NUMBER;
      vcapital       NUMBER;
      --Bug 27768/156180 - JSV - 17/10/2013 - INI
      vnpoliza       estseguros.npoliza%TYPE;
      vsproduc       estseguros.sproduc%TYPE;
      v_existe       NUMBER;
      v_escertif0    NUMBER;
      v_sseguro      seguros.sseguro%TYPE;
      nerr           NUMBER;
      v_cplan        NUMBER;
      v_finiefe      estgaranseg.ffinefe%TYPE;
      v_nmovimi      garanseg.nmovimi%TYPE;
      w_crespue4919  estpregunseg.crespue%TYPE;
      vuso           estautriesgos.cuso%TYPE;
      visuso         BOOLEAN;
   --Bug 27768/156180 - JSV - 17/10/2013 - FIN
   BEGIN
      -- Si entra en la funcion es porque la garantia esta contratada
      -- Se debe entonces informar el capital de la garantia con el valor
      -- que se ha seleccionado en la lista por pantalla o en su defecto
      -- por la garantia principal (igual que se hace en pac_md_produccion.p_set_garanprod)
      SELECT COUNT(1)
        INTO vcont
        FROM garanprocap g, estseguros s
       WHERE g.cramo = s.cramo
         AND g.cmodali = s.cmodali
         AND g.ctipseg = s.ctipseg
         AND g.ccolect = s.ccolect
         AND g.cgarant = pcgarant
         AND g.icapital = NVL(picapital, 0)
         AND s.sseguro = psseguro;

      IF vcont <> 0 THEN
         vcapital := NVL(picapital, 0);
      ELSE
         SELECT npoliza, sproduc
           INTO vnpoliza, vsproduc
           FROM estseguros
          WHERE sseguro = psseguro;

         isaltacol := FALSE;

         IF NVL(f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, psseguro);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe <= 0 THEN
                  isaltacol := TRUE;
               END IF;
            END IF;

            IF isaltacol THEN
               BEGIN
                  SELECT icapital
                    INTO vcapital
                    FROM garanprocap g, estseguros s
                   WHERE g.cramo = s.cramo
                     AND g.cmodali = s.cmodali
                     AND g.ctipseg = s.ctipseg
                     AND g.ccolect = s.ccolect
                     AND g.cgarant = pcgarant
                     AND g.cdefecto = 1
                     AND s.sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT icapital
                          INTO vcapital
                          FROM garanprocap g, estseguros s
                         WHERE g.cramo = s.cramo
                           AND g.cmodali = s.cmodali
                           AND g.ctipseg = s.ctipseg
                           AND g.ccolect = s.ccolect
                           AND g.cgarant = pcgarant
                           AND s.sseguro = psseguro
                           AND norden = (SELECT MIN(g2.norden)
                                           FROM garanprocap g2
                                          WHERE g.cramo = g2.cramo
                                            AND g.cmodali = g2.cmodali
                                            AND g.ctipseg = g2.ctipseg
                                            AND g.ccolect = g2.ccolect
                                            AND g.cgarant = g2.cgarant);
                     EXCEPTION
                        WHEN OTHERS THEN
                           vcapital := 0;
                     END;
                  WHEN OTHERS THEN
                     vcapital := 0;
               END;
            ELSE
               SELECT sseguro
                 INTO v_sseguro
                 FROM seguros
                WHERE npoliza = vnpoliza
                  AND ncertif = 0;

               nerr := pac_preguntas.f_get_pregunpolseg(psseguro, 4089, 'EST', v_cplan);

               IF nerr = 120135 THEN
                  v_cplan := 1;
               END IF;

               IF ptablas = 'EST' THEN
                  SELECT finiefe
                    INTO v_finiefe
                    FROM estgaranseg
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND nriesgo = pnriesgo
                     AND cgarant = pcgarant
                     AND nmovima = pnmovima;
               ELSE
                  SELECT finiefe
                    INTO v_finiefe
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND nriesgo = pnriesgo
                     AND cgarant = pcgarant
                     AND nmovima = pnmovima;
               END IF;

               SELECT DISTINCT nmovimi
                          INTO v_nmovimi
                          FROM garanseg gs
                         WHERE sseguro = v_sseguro
                           AND((finiefe <= v_finiefe)
                               AND(gs.ffinefe IS NULL
                                   OR gs.ffinefe > v_finiefe));

               BEGIN
                  IF ptablas = 'EST' THEN
                     SELECT crespue
                       INTO w_crespue4919
                       FROM estpregunseg
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND nmovimi = pnmovimi
                        AND cpregun = 4919;
                  ELSE
                     SELECT crespue
                       INTO w_crespue4919
                       FROM pregunseg
                      WHERE sseguro = psseguro
                        AND nriesgo = pnriesgo
                        AND nmovimi = pnmovimi
                        AND cpregun = 4919;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     visuso := TRUE;

                     IF ptablas = 'EST' THEN
                        SELECT cuso
                          INTO vuso
                          FROM estautriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = pnmovimi;
                     ELSE
                        SELECT cuso
                          INTO vuso
                          FROM autriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = pnriesgo
                           AND nmovimi = pnmovimi;
                     END IF;
               END;

               IF visuso THEN
                  vcapital := NVL(pac_subtablas_seg.f_vsubtabla_seg(-1, v_sseguro, v_cplan,
                                                                    pcgarant, v_nmovimi, 9098,
                                                                    3, 1, 'POL', vuso),
                                  0);
               ELSE
                  vcapital := NVL(pac_subtablas_seg.f_vsubtabla_seg(-1, v_sseguro, v_cplan,
                                                                    pcgarant, v_nmovimi, 9099,
                                                                    3, 1, 'POL',
                                                                    w_crespue4919),
                                  0);
               END IF;

               IF vcapital IS NULL THEN
                  BEGIN
                     SELECT icapital
                       INTO vcapital
                       FROM garanprocap g, estseguros s
                      WHERE g.cramo = s.cramo
                        AND g.cmodali = s.cmodali
                        AND g.ctipseg = s.ctipseg
                        AND g.ccolect = s.ccolect
                        AND g.cgarant = pcgarant
                        AND g.cdefecto = 1
                        AND s.sseguro = psseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        BEGIN
                           SELECT icapital
                             INTO vcapital
                             FROM garanprocap g, estseguros s
                            WHERE g.cramo = s.cramo
                              AND g.cmodali = s.cmodali
                              AND g.ctipseg = s.ctipseg
                              AND g.ccolect = s.ccolect
                              AND g.cgarant = pcgarant
                              AND s.sseguro = psseguro
                              AND norden = (SELECT MIN(g2.norden)
                                              FROM garanprocap g2
                                             WHERE g.cramo = g2.cramo
                                               AND g.cmodali = g2.cmodali
                                               AND g.ctipseg = g2.ctipseg
                                               AND g.ccolect = g2.ccolect
                                               AND g.cgarant = g2.cgarant);
                        EXCEPTION
                           WHEN OTHERS THEN
                              vcapital := 0;
                        END;
                     WHEN OTHERS THEN
                        vcapital := 0;
                  END;
               END IF;
            END IF;
         ELSE
            BEGIN
               SELECT icapital
                 INTO vcapital
                 FROM garanprocap g, estseguros s
                WHERE g.cramo = s.cramo
                  AND g.cmodali = s.cmodali
                  AND g.ctipseg = s.ctipseg
                  AND g.ccolect = s.ccolect
                  AND g.cgarant = pcgarant
                  AND g.cdefecto = 1
                  AND s.sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     SELECT icapital
                       INTO vcapital
                       FROM garanprocap g, estseguros s
                      WHERE g.cramo = s.cramo
                        AND g.cmodali = s.cmodali
                        AND g.ctipseg = s.ctipseg
                        AND g.ccolect = s.ccolect
                        AND g.cgarant = pcgarant
                        AND s.sseguro = psseguro
                        AND norden = (SELECT MIN(g2.norden)
                                        FROM garanprocap g2
                                       WHERE g.cramo = g2.cramo
                                         AND g.cmodali = g2.cmodali
                                         AND g.ctipseg = g2.ctipseg
                                         AND g.ccolect = g2.ccolect
                                         AND g.cgarant = g2.cgarant);
                  EXCEPTION
                     WHEN OTHERS THEN
                        vcapital := 0;
                  END;
               WHEN OTHERS THEN
                  vcapital := 0;
            END;
         END IF;
      END IF;

      UPDATE estgaranseg
         SET icapital = vcapital
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND cgarant = pcgarant
         AND nmovima = pnmovima;

      RETURN 0;
   END f_cargar_lista_valores;

   -- fin Bug 26923/148534 - APD - 08/07/2013
   FUNCTION f_borra_lista
      RETURN NUMBER IS
   BEGIN
      RETURN 0;
   END f_borra_lista;

   FUNCTION f_capital_maximo_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug.14322:ASN:28/04/2010.ini
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima NUMBER DEFAULT 1)   -- Bug.14322:ASN:28/04/2010.fin)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(10000)
         := 'psproduc = ' || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = '
            || pcgarant || '; psseguro = ' || psseguro || '; pnriesgo = ' || pnriesgo
            || '; pnmovimi = ' || pnmovimi;
      garpro         garanpro%ROWTYPE;
      vicapmax       garanpro.icapmax%TYPE;
      num_err        NUMBER;
      vftarifa       estgaranseg.ftarifa%TYPE;
   BEGIN
      vpasexec := 1;

      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = pcgarant
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cactivi = 0;
      END;

      vpasexec := 2;

      -- Bug 9699 - APD - 08/04/2009 - Fin

      -- Utilizamos los campos garanpro.ip_icapmax, y garanpro.ip_icapmin porque el capital máximo
      -- puede ir cambiando ON-LINE (depende del tipo de capital, etc...)
      IF garpro.ccapmax = 1 THEN   -- Fijo
         vpasexec := 3;
         RETURN garpro.icapmax;
      ELSIF garpro.ccapmax = 2 THEN   -- Depende de otro
         vpasexec := 4;

         -- Bug.14322:ASN:28/04/2010.ini
         -- Cuando el capital maximo depende de otro, entendemos que depende del capital contratado en GARANSEG
         BEGIN
            SELECT icapital * NVL(garpro.pcapdep, 100) / 100
              INTO vicapmax
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgardep;
         EXCEPTION
            WHEN OTHERS THEN
               vicapmax := NULL;
         END;

         /*
          -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
          -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
          BEGIN
             SELECT icapmax
               INTO vicapmax
               FROM garanpro
              WHERE sproduc = psproduc
                AND cgarant = garpro.cgardep
                AND cactivi = pcactivi;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                SELECT icapmax
                  INTO vicapmax
                  FROM garanpro
                 WHERE sproduc = psproduc
                   AND cgarant = garpro.cgardep
                   AND cactivi = 0;
          END;

          -- Bug 9699 - APD - 23/04/2009 - Fin
          */                                                                        -- Bug.14322:ASN:28/04/2010.fin
         RETURN vicapmax;
      -- Bug 21706 - APD - 24/04/2012 - se aNade el tipo ccapmax = 4.-Calculado
      ELSIF garpro.ccapmax = 4 THEN   -- Calculado (v.f.35)
         vpasexec := 5;

         BEGIN
            SELECT ftarifa
              INTO vftarifa
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgarant;
         EXCEPTION
            WHEN OTHERS THEN
               vftarifa := NULL;
         END;

         vpasexec := 6;
         num_err := pac_calculo_formulas.calc_formul(TRUNC(vftarifa), psproduc, garpro.cactivi,
                                                     pcgarant, pnriesgo, psseguro,
                                                     garpro.cclacap, vicapmax, pnmovimi, NULL,
                                                     1);
         vpasexec := 7;

         IF num_err <> 0 THEN
            --RETURN num_err;
            vicapmax := NULL;
         END IF;

         RETURN vicapmax;
      -- fin Bug 21706 - APD - 24/04/2012
      ELSE   -- Ilimitado
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_capital_maximo_garantia', vpasexec, vparam,
                     SQLERRM);
         RETURN NULL;   -- Error no controlado.
   END f_capital_maximo_garantia;

   FUNCTION f_valida_capital(
      paccion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER IS
      garpro         garanpro%ROWTYPE;
      estgar         estgaranseg%ROWTYPE;
      capmax         NUMBER;
      capmin         NUMBER;
      capital        estgaranseg.icapital%TYPE;
      vcforpag       estseguros.cforpag%TYPE;
      num_err        NUMBER;
      vcrespue       estpregunpolseg.crespue%TYPE;
      vctarman       NUMBER;
      v_noval        NUMBER;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cvalpar      pargaranpro.cvalpar%TYPE;
      v_pargar       NUMBER(10);
   BEGIN
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      IF pk_nueva_produccion.isaltacol THEN
         RETURN 0;
      END IF;

      SELECT *
        INTO estgar
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND nmovima = pnmovima
         AND cgarant = pcgarant;

      SELECT cforpag
        INTO vcforpag
        FROM estseguros
       WHERE sseguro = psseguro;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
        FROM productos
       WHERE sproduc = psproduc;

      -- incializamos la variable capital
      capital := estgar.icapital;
      --bug 19338 - ETM - 11/11/2011
      v_pargar := f_pargaranpro(v_cramo, v_cmodali, v_ctipseg, v_ccolect, pcactivi, pcgarant,
                                'TIPO', v_cvalpar);

      --FIN bug 19338 - ETM - 11/11/2011
      IF estgar.cobliga = 1
         AND estgar.icapital IS NOT NULL THEN
         --verificar que no supere ni el máximo ni el mínimo
         -- Bug 12426 - APD - 18/12/2009 - Si es un traspaso de entrada la aportacion periodica
         -- puede ser 0 (no se debe validar entonces el capital minimo), si no es un traspaso
         -- de entrada entonces sí se debe validar que el capital minimo.
         -- Se busca la respuesta de la pregunta 9003
         BEGIN
            SELECT e.crespue
              INTO vcrespue
              FROM estpregunpolseg e
             WHERE e.sseguro = psseguro
               AND e.cpregun = 9003
               AND e.nmovimi = (SELECT MAX(nmovimi)
                                  FROM estpregunpolseg e2
                                 WHERE e.sseguro = e2.sseguro
                                   AND e2.cpregun = 9003);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vcrespue := 0;
         END;

         IF vcrespue = 0 THEN   -- No es un traspaso de entrada
            --Estoy haciendo una suspensión del pago no valido el capital minimo en este caso
            IF pnmovimi > 1
               AND vcforpag = 0
               AND estgar.icapital = 0
               AND pac_parametros.f_pargaranpro_n(psproduc, pcactivi, pcgarant, 'TIPO') = 3 THEN
               v_noval := 1;
            ELSE
               v_noval := 0;
            END IF;

            IF NVL(v_noval, 0) <> 1 THEN
               num_err := f_validar_capitalmin(psproduc, pcactivi, vcforpag, estgar.cgarant,
                                               estgar.sseguro, estgar.nriesgo, estgar.nmovimi,   -- Bug 0026501 - MMS - 20130416
                                               estgar.icapital, capmin);
            END IF;
         END IF;

         -- Fin Bug 12426 - APD - 18/12/2009
         capmax := f_capital_maximo_garantia(psproduc, pcactivi, pcgarant, psseguro, pnriesgo,
                                             pnmovimi, pnmovima);   -- Bug.14322:ASN:28/04/2010

         IF num_err <> 0 THEN
            pmensa := capmin;

            IF capmax IS NOT NULL THEN
               pmensa := pmensa || ' - ' || capmax;

               IF v_pargar IN(3, 4) THEN   --f_prod_ahorro(psproduc) = 1 THEN
                  RETURN 180895;   -- prima entre capmin y capmax
               ELSE
                  RETURN 101681;   -- capital entre capmin y capmax
               END IF;
            END IF;

            IF v_pargar IN(3, 4) THEN   --f_prod_ahorro(psproduc) = 1 THEN
               RETURN 180896;   -- prima superior a capmin
            ELSE
               RETURN 180897;   -- capital superior a capmin
            END IF;
         END IF;

         IF isaltacol THEN
            capital := estgar.icapital;
         ELSE
            IF (estgar.icapital > capmax
                AND capmax IS NOT NULL)
               OR(estgar.icapital < NVL(capmin, 0)) THEN
               pmensa := NVL(capmin, 0) || '- ' || capmax;
               RETURN 101681;   -- El capital ha de tener nu valor entre
            ELSIF garpro.ctipcap = 1
                  AND estgar.icapital <> capmax THEN
               capital := capmax;
            ELSIF garpro.ctipcap = 4
                  AND estgar.icapital > 0 THEN
               capital := 0;
            END IF;
         END IF;
      ELSIF estgar.icapital IS NOT NULL THEN
         capital := NULL;

         UPDATE estgaranseg
            SET icapital = capital,
                iprianu = NULL
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND nmovima = pnmovima
            AND cgarant = pcgarant;

         RETURN 101680;
      ELSIF estgar.icapital IS NULL
            AND estgar.cobliga = 1
            AND garpro.ctipcap != 5 THEN   -- No sea calculada, bug 10702
         IF v_pargar IN(3, 4) THEN   --f_prod_ahorro(psproduc) = 1 THEN
            RETURN 151359;
         ELSE
            RETURN 101679;
         END IF;
      END IF;

      -- Bug 11735 - RSC - 27/01/2010 - APR - suplemento de modificación de capital /prima
      IF NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
         IF isaltacol THEN
            UPDATE estgaranseg
               SET icapital = capital
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND nmovima = pnmovima
               AND cgarant = pcgarant
               AND 1 <= (SELECT COUNT(*)
                           FROM estdetgaranseg
                          WHERE sseguro = psseguro
                            AND nmovimi = pnmovimi
                            AND nriesgo = pnriesgo
                            AND cgarant = pcgarant
                            AND cunica NOT IN(2));   -- Revisar para la modificación de garantías
         ELSE
            UPDATE estgaranseg
               SET icapital = capital,
                   iprianu = NULL
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND nmovima = pnmovima
               AND cgarant = pcgarant
               AND 1 <= (SELECT COUNT(*)
                           FROM estdetgaranseg
                          WHERE sseguro = psseguro
                            AND nmovimi = pnmovimi
                            AND nriesgo = pnriesgo
                            AND cgarant = pcgarant
                            AND cunica NOT IN(2));   -- Revisar para la modificación de garantías
         END IF;
      ELSE
         -- Fin Bug 11735
         SELECT NVL(ctarman, 0)
           INTO vctarman
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi
            AND nriesgo = pnriesgo
            AND nmovima = pnmovima
            AND cgarant = pcgarant;

         IF vctarman = 0 THEN
            UPDATE estgaranseg
               SET icapital = capital,
                   iprianu = NULL
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND nmovima = pnmovima
               AND cgarant = pcgarant;
         ELSE
            UPDATE estgaranseg
               SET icapital = capital
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND nmovima = pnmovima
               AND cgarant = pcgarant;
         END IF;
      END IF;

      num_err := f_valida_dependencias_k(paccion, psseguro, pnriesgo, pnmovimi, pcgarant,
                                         psproduc, pcactivi, pnmovima);

      IF num_err <> 0 THEN
         RETURN num_err;
      ELSE
         num_err := reseleccionar_gar_dependientes(psseguro, pnriesgo, pnmovimi, pcgarant,
                                                   'SEL', psproduc, pcactivi, pmensa,
                                                   pnmovima);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   END f_valida_capital;

   FUNCTION reseleccionar_gar_dependientes(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      paccion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima NUMBER DEFAULT 1)
      RETURN NUMBER IS
      CURSOR garantias IS
         -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         SELECT e.cgarant, e.nmovima, g.cgardep, e.cobliga
           FROM estgaranseg e, garanpro g
          WHERE e.sseguro = psseguro
            AND e.nriesgo = pnriesgo
            AND e.nmovimi = pnmovimi
            AND e.nmovima = pnmovima
            AND g.sproduc = psproduc
            AND g.cactivi = pcactivi
            AND g.cgarant = e.cgarant
         UNION
         SELECT e.cgarant, e.nmovima, g.cgardep, e.cobliga
           FROM estgaranseg e, garanpro g
          WHERE e.sseguro = psseguro
            AND e.nriesgo = pnriesgo
            AND e.nmovimi = pnmovimi
            AND e.nmovima = pnmovima
            AND g.sproduc = psproduc
            AND g.cactivi = 0
            AND g.cgarant = e.cgarant
            AND NOT EXISTS(SELECT e.cgarant, e.nmovima, g.cgardep, e.cobliga
                             FROM estgaranseg e, garanpro g
                            WHERE e.sseguro = psseguro
                              AND e.nriesgo = pnriesgo
                              AND e.nmovimi = pnmovimi
                              AND e.nmovima = pnmovima
                              AND g.sproduc = psproduc
                              AND g.cactivi = pcactivi
                              AND g.cgarant = e.cgarant);

      -- Bug 9699 - APD - 23/04/2009 - Fin
      num_err        NUMBER;
   BEGIN
      FOR c IN garantias LOOP
         IF c.cobliga = 1
            AND c.cgardep = pcgarant THEN
            num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, 'SEL',
                                            psproduc, pcactivi, pmensa, pnmovima);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   END reseleccionar_gar_dependientes;

   FUNCTION f_validar_garantias_al_tarifar(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER IS
      --
      CURSOR garantias IS
         SELECT   cgarant, nmovima
             FROM estgaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND cobliga = 1
         ORDER BY norden;   -- BUG 31992/0182922 - FAL - 03/09/2014 - QT: 13831

      -- Ini bug 18345 - SRA - 04/05/2011: cursor que recorre las garantías que no han sido marcadas
      CURSOR garantias_no_marcadas IS
         SELECT   cgarant, nmovima
             FROM estgaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND NVL(cobliga, 0) != 1
         ORDER BY norden;   -- BUG 31992/0182922 - FAL - 03/09/2014 - QT: 13831

      -- Fin bug 18345 - SRA - 04/05/2011
      num_err        NUMBER;
      e_cancela      EXCEPTION;
      e_cancela_pre  EXCEPTION;
      w_cgarant      garangen.cgarant%TYPE;
      vnsesion       NUMBER;
      vfefecto       DATE;
      vnpoliza       NUMBER;
      v_existe       NUMBER;
      v_escertif0    NUMBER;
      vsseguro       NUMBER;
      vmensa         VARCHAR2(10000);   -- BUG 29582/0164461 - APD - 28/01/2014
      v_gar_msj      VARCHAR2(10000) := ''; --IAXIS - 3104 - RABQ
      v_val_error    NUMBER;                -- IAXIS-4200 CJMR 05/08/2019 
	  
   BEGIN
      BEGIN
         SELECT npoliza, ssegpol
           INTO vnpoliza, vsseguro
           FROM estseguros
          WHERE sseguro = psseguro;

         IF NVL(f_parproductos_v(psproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
            -- AND NVL(f_parproductos_v(psproduc, 'DETALLE_GARANT'), 0) = 1 THEN-- INI bug 18631--ETM-30/05/2011
            v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, vsseguro);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe > 0 THEN
                  isaltacol := FALSE;
               ELSE
                  isaltacol := TRUE;
               END IF;
            END IF;
         ELSE
            isaltacol := FALSE;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            isaltacol := FALSE;
      END;

      SELECT fefecto
        INTO vfefecto
        FROM estseguros
       WHERE sseguro = psseguro;

      --BUG9216:DRA:23-02-2009:Comprobamos si hay seleccionada alguna garantía básica
      p_define_modo('EST');
      --- Valida alguna garantia seleccionada basica
      num_err := pk_nueva_produccion.f_comprueba_basicos(psseguro, NULL, pnriesgo, psproduc,
                                                         pcactivi, pnmovimi);

      IF num_err <> 0 THEN
         RAISE e_cancela;
      END IF;

      -- Valida alguna garantia seleccionada
      -- IAXIS - 3104 - RABQ
      num_err := pk_nueva_produccion.f_valida_marcadas(psseguro, pnriesgo, pnmovimi);

      /*IF num_err <> 0 THEN
         RAISE e_cancela;
      END IF;*/

      -- BUG9496:DRA:12/05/2009:Inici
      FOR c IN garantias LOOP
         w_cgarant := c.cgarant;
         num_err := pk_nueva_produccion.f_validacion_cobliga(psseguro, pnriesgo, pnmovimi,
                                                             c.cgarant, 'SEL', psproduc,
                                                             pcactivi, pmensa, c.nmovima);

         IF num_err <> 0 THEN
            -- Ini bug 18345 - SRA - 10/05/2011
            IF TRIM(pmensa) IS NOT NULL THEN
               RETURN num_err;
            END IF;

            -- Fin bug 18345 - SRA - 10/05/2011
            RAISE e_cancela;
         END IF;

         num_err := pk_nueva_produccion.f_valida_capital('SEL', psseguro, pnriesgo, pnmovimi,
                                                         c.cgarant, psproduc, pcactivi, pmensa,
                                                         c.nmovima);

         IF num_err NOT IN
               (0, 101680)   -- Si la garantia la ha deseleccionado la funcion f_validacion_cobliga
                          THEN
            RAISE e_cancela;
         END IF;

         -- BUG9496:17/03/2009:DRA:Validem que estiguin contestades les preg. obligatories
         num_err := pk_nueva_produccion.f_valida_pregun_garant(psseguro, pnriesgo, pnmovimi,
                                                               psproduc, pcactivi, w_cgarant,
                                                               pmensa);

         IF num_err <> 0 THEN
            RAISE e_cancela;
         END IF;

         -- BUG9496:DRA:12/05/2009:Fi

         -- Bug 20163/98005 - RSC - 15/11/2011
         num_err := f_valida_garanproval(w_cgarant, psseguro, pnriesgo, pnmovimi, psproduc,
                                         pcactivi, pmensa, 'PRE');

      -- INI IAXIS-3408 - RABQ
         IF num_err <> 0 THEN
            v_gar_msj := 'Amparo: '|| pmensa || '<br>' || v_gar_msj;
            v_val_error := num_err;      -- IAXIS-4200 CJMR 05/08/2019
         END IF;
      -- Fin Bug 20163/98005
      END LOOP;

      --IF num_err <> 0 THEN                          -- IAXIS-4200 CJMR 05/08/2019
      IF num_err <> 0 OR v_val_error <> 0 THEN        -- IAXIS-4200 CJMR 05/08/2019
        RAISE e_cancela;
      END IF;
      -- END IAXIS-3408 - RABQ

      -- Ini bug 18345 - SRA - 03/05/2011: aNadimos llamada a la función que recupera las validaciones que se han
      -- definido para la combinación de garantía/producto/actividad en aquellas garantías que no se han marcado
      FOR c IN garantias_no_marcadas LOOP
         DECLARE
            vtparam        tab_error.tdescrip%TYPE;
         BEGIN
            w_cgarant := c.cgarant;
            vtparam := 'psseguro: ' || psseguro || ' - ' || 'psproduc: ' || psproduc || ' - '
                       || 'pnriesgo: ' || pnriesgo || ' - ' || 'pnmovimi: ' || pnmovimi
                       || ' - ' || 'pcactivi: ' || pcactivi || ' - ' || 'cgarant: '
                       || c.cgarant || ' - ';
            num_err := f_valida_garanproval(c.cgarant, psseguro, pnriesgo, pnmovimi, psproduc,
                                            pcactivi, pmensa, 'PRE');

            IF num_err <> 0 THEN
               IF TRIM(pmensa) IS NULL THEN
                  pmensa := ff_desgarantia(w_cgarant, f_usu_idioma);
               END IF;

               RETURN num_err;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user,
                           'pk_nueva_produccion.f_validar_garantias_al_tarifar', 99, vtparam,
                           SQLERRM);
               RAISE;
         END;
      END LOOP;

      -- Fin bug 18345 - SRA - 03/05/2011
      RETURN 0;
   EXCEPTION
      WHEN e_cancela THEN
         -- BUG 29582/0164461 - APD - 28/01/2014
         /*
         IF pmensa IS NOT NULL
            OR w_cgarant IS NOT NULL THEN
            pmensa := aux_f_desgarantia(w_cgarant) || ' - ' || pmensa;
         END IF;
         */
         -- INI IAXIS-3408 - RABQ
         IF w_cgarant IS NOT NULL THEN
            vmensa := pmensa || vmensa;
            pmensa := v_gar_msj;

            IF vmensa IS NOT NULL THEN
               pmensa := v_gar_msj;

            END IF;
         END IF;
         -- END IAXIS-3408 - RABQ

         -- fin BUG 29582/0164461 - APD - 28/01/2014
         -- INI IAXIS-4200 CJMR 05/08/2019
		 IF v_val_error <> 0  AND num_err <> v_val_error THEN
            --pmensa := '';  CJMR
            RETURN v_val_error;
         END IF;
		 -- FIN IAXIS-4200 CJMR 05/08/2019
		 
         RETURN num_err;
		 
   END f_validar_garantias_al_tarifar;

   FUNCTION f_validar_garantias(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      vcrevali       estseguros.crevali%TYPE;
      vprevali       estseguros.prevali%TYPE;
      virevali       estseguros.irevali%TYPE;
      vcforpag       estseguros.cforpag%TYPE;
      vsproduc       estseguros.sproduc%TYPE;
      vssegpol       estseguros.ssegpol%TYPE;
      vcforpag2      seguros.cforpag%TYPE;
      vcactivi       estseguros.cactivi%TYPE;
   BEGIN
      --verificamos que las garantias marcadas han sido tarifadas
      SELECT COUNT(1)
        INTO num_err
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nmovimi = pnmovimi
         AND nriesgo = pnriesgo
         AND cobliga = 1
         AND ctipgar <> 8
         AND iprianu IS NULL;

      IF num_err > 0 THEN
         RETURN 101689;   --falta tarifar les garanties
      END IF;

      --actualizamos la revalorización, con el tipo e importe que tiene en seguros
      BEGIN
         -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         SELECT crevali, prevali, irevali, cforpag, sproduc, ssegpol,
                pac_seguros.ff_get_actividad(sseguro, pnriesgo, 'EST') cactivi
           INTO vcrevali, vprevali, virevali, vcforpag, vsproduc, vssegpol,
                vcactivi
           FROM estseguros
          WHERE sseguro = psseguro;

         -- Bug 9699 - APD - 23/04/2009 - fin

         -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
         -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
         UPDATE estgaranseg
            SET crevali = vcrevali,
                prevali = vprevali,
                irevali = virevali
          WHERE sseguro = psseguro
            AND cgarant IN(SELECT cgarant
                             FROM garanpro
                            WHERE sproduc = vsproduc
                              AND cactivi = vcactivi
                              AND crevali <> 0
                           UNION
                           SELECT cgarant
                             FROM garanpro
                            WHERE sproduc = vsproduc
                              AND cactivi = 0
                              AND crevali <> 0
                              AND NOT EXISTS(SELECT cgarant
                                               FROM garanpro
                                              WHERE sproduc = vsproduc
                                                AND cactivi = vcactivi
                                                AND crevali <> 0));
      -- Bug 9699 - APD - 23/04/2009 - Fin
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 111399;   --Falta el importe o tipo de revalorización
      END;

      IF NVL(pnmovimi, 1) > 1 THEN
         -- miramos si nos han hecho una suspensión.
         IF f_parproductos_v(vsproduc, 'SUSPENSION') = 0 THEN
            BEGIN
               SELECT cforpag
                 INTO vcforpag2
                 FROM seguros
                WHERE sseguro = vssegpol;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 102903;   --{No s'ha trobat cap registre}
            END;

            IF vcforpag = 0
               AND vcforpag2 <> 0 THEN
               RETURN 151375;   --No se permite un cambio a forma de pago única
            END IF;
         END IF;
      END IF;

      RETURN 0;
   END f_validar_garantias;

   PROCEDURE p_modificar_fefecto_seg(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      v_pfefecto     DATE := pfefecto;
      v_ffinefe      DATE;
      v_nrenova      NUMBER;
      v_nerror       NUMBER;
      v_sproduc      seguros.sproduc%TYPE;
      v_texterr      VARCHAR2(200);
      v_existen      NUMBER;   -- BUG11458:DRA:14/10/2009
      v_existen_gar  NUMBER;   -- BUG11458:DRA:14/10/2009
      v_fefecto      DATE;
      v_ftarifa      DATE;   -- Bug 18848 - APD - 22/06/2011
      v_ftarifa2     DATE;   -- Bug 18848 - APD - 22/06/2011
      vnumerr        NUMBER;   -- Bug 18848 - APD - 22/06/2011
      v_cduraci      NUMBER;
      v_nrenova_seg  NUMBER;
      v_nrenova_aux  NUMBER;
   BEGIN
      -- Bug 18848 - APD - 22/06/2011
      -- si 'FECHA_TARIFA' = 1.- Fecha de efecto --> tal y como funciona hasta ahora
      -- si 'FECHA_TARIFA' = 2.- Fecha de grabacion inicial --> FTARIFA = F_SYSDATE
      vnumerr := pac_seguros.f_get_sproduc(psseguro, ptablas, v_sproduc);

      IF NVL(f_parproductos_v(v_sproduc, 'FECHA_TARIFA'), 1) = 1 THEN   -- Fecha de efecto
         v_ftarifa := v_pfefecto;
      ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHA_TARIFA'), 1) = 2 THEN   -- Fecha de grabacion inicial
         v_ftarifa := NULL;   -- no se debe modificar la fecha tarifa
      END IF;

      -- Fin Bug 18848 - APD - 22/06/2011
      IF ptablas = 'EST' THEN
         UPDATE estriesgos
            SET fefecto = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovima = pnmovimi;

         --garantias del movimiento actual
         UPDATE estgaranseg
            SET finiefe = v_pfefecto   --,
          --ftarifa = v_pfefecto -- Bug 18848 - APD - 22/06/2011
         WHERE  sseguro = psseguro
            AND nmovimi = pnmovimi;

         -- Bug 18848 - APD - 22/06/2011
         -- el campo FTARIFA solo debe modificarse si v_ftarifa IS NOT NULL
         IF v_ftarifa IS NOT NULL THEN
            UPDATE estgaranseg
               SET ftarifa = v_ftarifa
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
         END IF;

         -- Fin Bug 18848 - APD - 22/06/2011

         --garantias del movimiento actual
         --XPL 16092009 - S'eliminar la FK i s'afegeix l'update per tenir-ho actualitzat.
         UPDATE estdetgaranseg
            SET finiefe = v_pfefecto,
                --ftarifa = v_pfefecto, -- Bug 18848 - APD - 22/06/2011
                fefecto = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         -- Bug 18848 - APD - 22/06/2011
         -- el campo FTARIFA solo debe modificarse si v_ftarifa IS NOT NULL
         IF v_ftarifa IS NOT NULL THEN
            UPDATE estdetgaranseg
               SET ftarifa = v_ftarifa
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
         END IF;

         -- Fin Bug 18848 - APD - 22/06/2011

         /* --garantias del movimiento anterior
            --(falta la ftarifa habría que jugar con el nmovima)
            UPDATE estgaranseg
               SET ffinefe = pfefecto
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi-1;*/
         UPDATE estclaubenseg
            SET finiclau = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE estclausuesp
            SET finiclau = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE estclaususeg
            SET finiclau = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE estcoacuadro
            SET finicoa = v_pfefecto
          WHERE sseguro = psseguro;

         UPDATE estpregungaranseg
            SET finiefe = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE estassegurats
            SET ffecini = v_pfefecto
          WHERE sseguro = psseguro;

         UPDATE estautdetriesgos
            SET fini = v_pfefecto
          WHERE sseguro = psseguro;

         UPDATE estgaransegcom
            SET finiefe = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         -- Bug 21121 - APD - 21/02/2012 - se incluye la tabla estdetprimas
         UPDATE estdetprimas
            SET finiefe = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         -- fin Bug 21121 - APD - 21/02/2012
         UPDATE estgaranseggas
            SET finiefe = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE estmotretencion
            SET freten = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
      ELSE
         -- BUG9523:18/03/2009:DRA
         SELECT sproduc, fefecto, cduraci, nrenova
           INTO v_sproduc, v_fefecto, v_cduraci, v_nrenova_seg
           FROM seguros
          WHERE sseguro = psseguro;

         v_nerror := pac_calc_comu.f_calcula_nrenova(v_sproduc, v_fefecto, v_nrenova_aux);

         IF v_cduraci <> 6 THEN
            v_nerror := pac_calc_comu.f_calcula_nrenova(v_sproduc, v_pfefecto, v_nrenova);
         ELSE
            v_nrenova := v_nrenova_seg;
         END IF;

         IF v_nerror <> 0 THEN
            v_texterr := f_axis_literales(v_nerror, f_usu_idioma);
            p_tab_error(f_sysdate, f_user, 'p_modificar_fefecto_seg', 1,
                        'Producto: ' || v_sproduc || '- Fecha: ' || v_pfefecto || '- Error: '
                        || v_nerror,
                        v_texterr);
            raise_application_error(-20000, v_texterr);
         END IF;

         --bug 18802--22/06/2011--etm-
         IF v_fefecto <> pfefecto THEN
            IF v_nrenova_seg <> v_nrenova_aux THEN
               -- NRENOVA grabada manualmente --> No tocamos el NRENOVA.
               UPDATE seguros
                  SET fefecto = v_pfefecto
                WHERE sseguro = psseguro
                  AND 1 = pnmovimi;
            ELSE
               UPDATE seguros
                  SET fefecto = v_pfefecto,
                      nrenova = v_nrenova
                WHERE sseguro = psseguro
                  AND 1 = pnmovimi;
            END IF;
         END IF;

         UPDATE riesgos
            SET fefecto = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovima = pnmovimi;

         -- BUG11458:DRA:14/10/2009:Inici: Miramos si hay detalles
         SELECT COUNT(1)
           INTO v_existen
           FROM (SELECT 1
                   FROM detgaranseg d
                  WHERE d.sseguro = psseguro
                    AND d.nmovimi = pnmovimi
                 UNION ALL
                 SELECT 1
                   FROM comisigaranseg cg
                  WHERE cg.sseguro = psseguro
                    AND cg.nmovimi = pnmovimi
                 -- Bug 21121 - JRH - 21/02/2012 - se incluye la tabla detprimas
                 UNION ALL
                 SELECT 1
                   FROM detprimas dp
                  WHERE dp.sseguro = psseguro
                    AND dp.nmovimi = pnmovimi
                                             -- Fi Bug 21121 - JRH - 21/02/2012
                );

         IF v_existen > 0 THEN   -- Si hay detalles modificamos
            -- Si hay alguna garantia con la misma fecha efecto no duplicamos
            SELECT COUNT(1)
              INTO v_existen_gar
              FROM garanseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND finiefe = v_pfefecto;

            IF v_existen_gar = 0 THEN
               -- BUG10947:DRA:18/09/2009:Inici: Si tiene detalle, por ser la FINIEFE PK hay que hacer lo siguiente
               -- Bug 18848 - APD - 22/06/2011
               -- si 'FECHA_TARIFA' = 1.- Fecha de efecto --> tal y como funciona hasta ahora
               -- si 'FECHA_TARIFA' = 2.- Fecha de grabacion inicial --> FTARIFA = F_SYSDATE
               IF NVL(f_parproductos_v(v_sproduc, 'FECHA_TARIFA'), 1) = 1 THEN   -- Fecha de efecto
                  v_ftarifa2 := v_pfefecto;
               ELSIF NVL(f_parproductos_v(v_sproduc, 'FECHA_TARIFA'), 1) = 2 THEN   -- Fecha de grabacion inicial
                  v_ftarifa2 := TRUNC(f_sysdate);
               END IF;

               -- se sustituye el valor v_pfefecto por v_ftarifa2 que será el que
               -- se inserte en el campo garanseg.ftarifa
               -- FBL. 25/06/2014 MSV Bug 0028974
               INSERT INTO garanseg
                           (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                            ctarifa, icapital, precarg, iextrap, iprianu, ffinefe, cformul,
                            ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                            irevali, itarifa, itarrea, ipritot, icaptot, pdtoint, idtoint,
                            ftarifa, feprev, fpprev, percre, crevalcar, cmatch, tdesmat,
                            pintfin, cref, cintref, pdif, pinttec, nparben, nbns, tmgaran,
                            cderreg, ccampanya, nversio, nmovima, cageven, nfactor, nlinea,
                            cmotmov, finider, falta, cfranq, nfraver, ngrpfra, ngrpgara,
                            pdtofra, ctarman, nordfra, ipricom, finivig, ffinvig)
                  SELECT cgarant, nriesgo, nmovimi, sseguro, v_pfefecto, norden, crevali,
                         ctarifa, icapital, precarg, iextrap, iprianu, ffinefe, cformul,
                         ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                         irevali, itarifa, itarrea, ipritot, icaptot, pdtoint, idtoint,
                         v_ftarifa2 /*v_pfefecto*/, feprev, fpprev, percre, crevalcar, cmatch,
                         tdesmat, pintfin, cref, cintref, pdif, pinttec, nparben, nbns,
                         tmgaran, cderreg, ccampanya, nversio, nmovima, cageven, nfactor,
                         nlinea, cmotmov, finider, falta, cfranq, nfraver, ngrpfra, ngrpgara,
                         pdtofra, ctarman, nordfra, ipricom, finivig, ffinvig
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi;
             -- Fin FBL. 25/06/2014 MSV Bug 0028974
            -- Fin Bug 18848 - APD - 22/06/2011
            END IF;

            UPDATE detgaranseg
               SET finiefe = v_pfefecto,
                   --ftarifa = v_pfefecto, -- Bug 18848 - APD - 22/06/2011
                   fefecto = v_pfefecto
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            -- Bug 18848 - APD - 22/06/2011
            -- el campo FTARIFA solo debe modificarse si v_ftarifa IS NOT NULL
            IF v_ftarifa IS NOT NULL THEN
               UPDATE detgaranseg
                  SET ftarifa = v_ftarifa
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi;
            END IF;

            -- Fin Bug 18848 - APD -
            UPDATE comisigaranseg
               SET finiefe = v_pfefecto
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            UPDATE detprimas
               SET finiefe = v_pfefecto
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            -- Si se ha duplicado borramos las garantias del mismo nmovimi y diferente FINIEFE
            IF v_existen_gar = 0 THEN
               DELETE FROM garanseg
                     WHERE sseguro = psseguro
                       AND nmovimi = pnmovimi
                       AND finiefe <> v_pfefecto;
            END IF;
         -- BUG10947:DRA:18/09/2009:Fi
         END IF;

         -- BUG11458:DRA:14/10/2009:Fi
         UPDATE garanseg
            SET finiefe = v_pfefecto   --,
          --ftarifa = v_pfefecto  -- Bug 18848 - APD - 22/06/2011
         WHERE  sseguro = psseguro
            AND nmovimi = pnmovimi;

         -- Bug 18848 - APD - 22/06/2011
         -- el campo FTARIFA solo debe modificarse si v_ftarifa IS NOT NULL
         IF v_ftarifa IS NOT NULL THEN
            UPDATE garanseg
               SET ftarifa = v_ftarifa
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;
         END IF;

         -- Fin Bug 18848 - APD

         /* --garantias del movimiento anterior
            --(falta la ftarifa habría que jugar con el nmovima)
            UPDATE estgaranseg
               SET ffinefe = pfefecto
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi-1;*/
         UPDATE claubenseg
            SET finiclau = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE clausuesp
            SET finiclau = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE claususeg
            SET finiclau = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE coacuadro
            SET finicoa = v_pfefecto
          WHERE sseguro = psseguro;

         UPDATE pregungaranseg
            SET finiefe = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE asegurados
            SET ffecini = v_pfefecto
          WHERE sseguro = psseguro;

         UPDATE autdetriesgos
            SET fini = v_pfefecto
          WHERE sseguro = psseguro;

         UPDATE garansegcom
            SET finiefe = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         -- Bug 21121 - APD - 21/02/2012 - se incluye la tabla detprimas
--         UPDATE detprimas
--            SET finiefe = v_pfefecto
--          WHERE sseguro = psseguro
--            AND nmovimi = pnmovimi;

         -- fin Bug 21121 - APD - 21/02/2012
         UPDATE garanseggas
            SET finiefe = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE motretencion
            SET freten = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;

         UPDATE movseguro
            SET fefecto = v_pfefecto
          WHERE sseguro = psseguro
            AND nmovimi = pnmovimi;
      END IF;
   END p_modificar_fefecto_seg;

   FUNCTION f_marcar_basicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      CURSOR garantias_a_marcar IS
         SELECT cgarant, nmovima, ctipgar, icapital
           FROM estgaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND ctipgar = 2;

      num_err        NUMBER;
      v_mensa        VARCHAR2(500);
   BEGIN
      -- desmarcamos todas las garantias para que
      -- no tengamos problemas de dependencias
      UPDATE estgaranseg
         SET cobliga = 0,
             iprianu = NULL
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND ctipgar = 2;

      UPDATE estgaranseg
         SET cobliga = 0,
             icapital = NULL,
             iprianu = NULL
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND ctipgar <> 2;

      FOR c IN garantias_a_marcar LOOP
         --validamos la edad, y solo marcamos aquella que cumplen la edad.
         num_err := f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi, c.cgarant);

         -- no devolvemos el error si no que las que ni cumplen no se marcan
         IF num_err = 0
            AND f_valida_exclugarseg('EST', psseguro, pnriesgo, c.cgarant) = 0 THEN
            UPDATE estgaranseg
               SET cobliga = 1,
                   icapital = NVL(c.icapital, 0)
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cgarant = c.cgarant;

            --llamo a la función para que me marque las dependientes
            -- obligatorias de las obligatorias
            num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, 'SEL',
                                            psproduc, pcactivi, v_mensa, c.nmovima);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END LOOP;

      COMMIT;
      RETURN 0;
   END f_marcar_basicas;

   FUNCTION f_marcar_completo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;

      CURSOR garantias IS
         SELECT   cgarant, nmovima, ctipgar, icapital
             FROM estgaranseg
            WHERE sseguro = psseguro
              AND nriesgo = pnriesgo
              AND nmovimi = pnmovimi
         ORDER BY ctipgar;

      v_mensa        VARCHAR2(100);
      vicapital      estgaranseg.icapital%TYPE;
   BEGIN
      -- miramos si hay incompatibles, si no hay las marcamos todas,
      --en caso contrario retornamos un error.
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      DECLARE
         v_cactivi      garanpro.cactivi%TYPE;
      BEGIN
         --BUG9748 - 09/04/2009 - JTS - IAX -ACTIVIDAD - Selects contra INCOMPAGARAN, tener en cuenta la actividad
         SELECT DECODE(COUNT(*), 0, 0, pcactivi)
           INTO v_cactivi
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi;

         --Fi BUG9748
         SELECT COUNT(1)
           INTO num_err
           FROM incompgaran i, garanpro g
          WHERE i.cramo = g.cramo
            AND i.cmodali = g.cmodali
            AND i.ctipseg = g.ctipseg
            AND i.ccolect = g.ccolect
            AND i.cactivi = g.cactivi
            AND i.cgarant = g.cgarant
            AND g.sproduc = psproduc
            AND g.cactivi = v_cactivi;
      END;

      -- Bug 9699 - APD - 23/04/2009 - Fin
      IF num_err > 0 THEN
         RETURN 151247;
      END IF;

      FOR c IN garantias LOOP
         --validamos la edad, y solo marcamos aquella que cumplen la edad.
         num_err := f_validar_edad(psseguro, pnriesgo, psproduc, pcactivi, c.cgarant);

         -- no devolvemos el error si no que las que ni cumplen no se marcan
         IF num_err = 0
            AND f_valida_exclugarseg('EST', psseguro, pnriesgo, c.cgarant) = 0 THEN
            IF c.ctipgar = 2 THEN
               vicapital := NVL(c.icapital, 0);
            ELSE
               vicapital := 0;
            END IF;

            UPDATE estgaranseg
               SET cobliga = 1,
                   icapital = vicapital,
                   iprianu = NULL
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cgarant = c.cgarant;

            --llamo a la función para que me marque las dependientes
            -- obligatorias de las obligatorias
            num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, c.cgarant, 'SEL',
                                            psproduc, pcactivi, v_mensa, c.nmovima);

            IF num_err <> 0 THEN
               COMMIT;
               RETURN num_err;
            END IF;
         ELSE
            UPDATE estgaranseg
               SET cobliga = 0,
                   icapital = NULL,
                   iprianu = NULL
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo
               AND nmovimi = pnmovimi
               AND cgarant = c.cgarant;
         END IF;
      END LOOP;

      COMMIT;
      RETURN 0;
   END f_marcar_completo;

   FUNCTION f_primas_a_null(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      UPDATE estgaranseg
         SET iprianu = NULL
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = pnmovimi;

      COMMIT;
      RETURN 0;
   END f_primas_a_null;

   FUNCTION f_oficina_mv
      RETURN NUMBER AS
      v_oficina      NUMBER;
      verror         NUMBER;
      vuserbd        VARCHAR2(20);
      vtipousuario   NUMBER;
   BEGIN
      vuserbd := f_os_user;
      verror := pac_ctrl_acceso_mv.tipo_usuario(vuserbd, vtipousuario);

      IF verror <> 0 THEN
         RETURN NULL;
      END IF;

      IF vtipousuario = 2 THEN   -- usuari de desenvolupament
         v_oficina := 252;
      ELSIF vtipousuario = 0 THEN   -- usuari de la central
         v_oficina := f_parinstalacion_n('OF_MOVSEG');
      ELSIF vtipousuario = 1 THEN   -- usuari del terminal financer
         vuserbd := 'TF_' || vuserbd;

         SELECT coficina
           INTO v_oficina
           FROM log_conexion
          WHERE session_id = f_session
            AND cusuari = vuserbd;
      ELSE
         RETURN NULL;
      END IF;

      RETURN v_oficina;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BEGIN
            RETURN NULL;
         END;
      WHEN OTHERS THEN
         RETURN NULL;
   END f_oficina_mv;

   FUNCTION f_validar_capitalmin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug 0026501 - MMS - 20130416
      pnriesgo IN NUMBER,   -- Bug 0026501 - MMS - 20130416
      pnmovimi IN NUMBER,   -- Bug 0026501 - MMS - 20130416
      pcicapital IN NUMBER,
      pcicapmin IN OUT NUMBER)
      RETURN NUMBER IS
      vccapmin       garanpro.ccapmin%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cvalpar      pargaranpro.cvalpar%TYPE;
      v_pargar       NUMBER(10);
   BEGIN
      -- miramos que tipo de capital mínimo tiene
      -- 0 .- fijo, 1.- segun forma de pago
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
        FROM productos
       WHERE sproduc = psproduc;

      BEGIN
         SELECT ccapmin, icapmin
           INTO vccapmin, pcicapmin
           FROM garanpro
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT ccapmin, icapmin
              INTO vccapmin, pcicapmin
              FROM garanpro
             WHERE sproduc = psproduc
               AND cactivi = 0
               AND cgarant = pcgarant;
      END;

      pcicapmin := pk_nueva_produccion.f_capital_minimo_garantia(psproduc, pcactivi, pcgarant,
                                                                 psseguro, pnriesgo, pnmovimi);   -- Bug 0026501 - MMS - 20130416

      -- Bug 9699 - APD - 23/04/2009 - Fin
      IF NVL(vccapmin, 0) = 1 THEN
         BEGIN
            SELECT icapmin
              INTO pcicapmin
              FROM capitalmin
             WHERE sproduc = psproduc
               AND cactivi = pcactivi
               AND cforpag = pcforpag
               AND cgarant = pcgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT icapmin
                    INTO pcicapmin
                    FROM capitalmin
                   WHERE sproduc = psproduc
                     AND cactivi = 0
                     AND cforpag = pcforpag
                     AND cgarant = pcgarant;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;   -- si no está es que no límit mínim
               END;
         END;
      END IF;

      --bug 19338 - ETM - 11/11/2011
      v_pargar := f_pargaranpro(v_cramo, v_cmodali, v_ctipseg, v_ccolect, pcactivi, pcgarant,
                                'TIPO', v_cvalpar);

      --FIN bug 19338 - ETM - 11/11/2011
      IF pcicapmin IS NOT NULL
         AND pcicapmin > pcicapital THEN
         IF v_pargar IN(3, 4) THEN   --f_prod_ahorro(psproduc) = 1 THEN
            RETURN 151289;   --La prima no supera la prima mínima
         ELSE
            RETURN 101983;
         END IF;
      END IF;

      RETURN 0;
   END f_validar_capitalmin;

   FUNCTION f_validar_aport_max(
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefepol IN DATE,
      psperson IN NUMBER,
      pcforpag IN NUMBER,
      pnrenova IN VARCHAR2,
      psproduc IN NUMBER,
      pfcarpro IN DATE)
      RETURN NUMBER IS
      num_err        NUMBER;
   BEGIN
      -- LLamamos al Pac_Propio. Cada isntalación valida las aportaciones máximas de una forma diferente
      num_err := pac_propio.f_validar_aport_max(pmodo, psseguro, pnriesgo, pnmovimi, pfefepol,
                                                psperson, pcforpag, pnrenova, psproduc,
                                                pfcarpro);
      RETURN num_err;
   END f_validar_aport_max;

--JRH 09/2007 Tarea 2674: Intereses para LRC.ANadimos los nuevos campos ndesde y nhasta para modificar la tabla.
   FUNCTION f_ins_intertecseg(
      ptabla IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefemov IN DATE,
      ppinttec IN NUMBER,
      pninttec IN NUMBER,
      pndesde IN NUMBER DEFAULT 0,
      pnhasta IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vndesde        NUMBER;
      vnhasta        NUMBER;
      vcmodint       productos.cmodint%TYPE;
   BEGIN
      vndesde := NVL(pndesde, 0);
      vnhasta := NVL(pnhasta, 0);

      IF ptabla = 'EST' THEN
         SELECT cmodint
           INTO vcmodint
           FROM estseguros s, productos p
          WHERE sseguro = psseguro
            AND p.sproduc = s.sproduc;

         IF vcmodint = 0 THEN
            RETURN 0;
         ELSE
            BEGIN
               INSERT INTO estintertecseg
                           (sseguro, nmovimi, fefemov, fmovdia, pinttec,
                            ndesde, nhasta, ninntec)
                    VALUES (psseguro, pnmovimi, TRUNC(pfefemov), TRUNC(f_sysdate), ppinttec,
                            vndesde, vnhasta, pninttec);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE estintertecseg
                     SET nmovimi = pnmovimi,
                         fefemov = TRUNC(pfefemov),
                         fmovdia = TRUNC(f_sysdate),
                         pinttec = ppinttec,
                         ndesde = vndesde,
                         nhasta = vnhasta,
                         ninntec = pninttec
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND ndesde = vndesde
                     AND nhasta = vnhasta;
            END;
         END IF;
      ELSE
         SELECT cmodint
           INTO vcmodint
           FROM seguros s, productos p
          WHERE sseguro = psseguro
            AND p.sproduc = s.sproduc;

         IF vcmodint = 0 THEN
            RETURN 0;
         ELSE
            BEGIN
               INSERT INTO intertecseg
                           (sseguro, nmovimi, fefemov, fmovdia, pinttec,
                            ndesde, nhasta, ninntec)
                    VALUES (psseguro, pnmovimi, TRUNC(pfefemov), TRUNC(f_sysdate), ppinttec,
                            vndesde, vnhasta, pninttec);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  UPDATE intertecseg
                     SET nmovimi = pnmovimi,
                         fefemov = TRUNC(pfefemov),
                         fmovdia = TRUNC(f_sysdate),
                         ndesde = vndesde,
                         nhasta = vnhasta,
                         pinttec = ppinttec,
                         ninntec = pninttec
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi
                     AND ndesde = vndesde
                     AND nhasta = vnhasta;
            END;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 104742;
   END f_ins_intertecseg;

   FUNCTION f_valida_exclugarseg(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      v_cgarant      estexclugarseg.cgarant%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT cgarant
           INTO v_cgarant
           FROM estexclugarseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimb IS NULL
            AND cgarant = pcgarant;

         RETURN 1;
      ELSE
         SELECT cgarant
           INTO v_cgarant
           FROM exclugarseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimb IS NULL
            AND cgarant = pcgarant;

         RETURN 1;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_valida_exclugarseg;

   FUNCTION f_inserta_estpresttitulares(pctapres IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER IS
      -- Bub 11301 - APD - 22/10/2009 - se recupera tambien el campo falta para aNadirlo
      -- en el insert de la tabla estpresttitulares
      -- Bug 0012802 - 20/01/2010 - JMF
      CURSOR titulares IS
         SELECT ctapres, norden, snip, falta
           FROM presttitulares p
          WHERE ctapres = pctapres
            AND(ctapres, snip) NOT IN(SELECT ctapres, snip
                                        FROM seguros s, prestamoseg x, per_personas z,
                                             tomadores t
                                       WHERE x.ctapres = p.ctapres
                                         AND z.snip = p.snip
                                         AND z.sperson = t.sperson
                                         AND x.sseguro = t.sseguro
                                         AND s.sseguro = x.sseguro
                                         AND(f_vigente(x.sseguro, NULL, f_sysdate) = 0
                                             OR s.csituac = 4
                                                AND s.creteni NOT IN(3, 4)));

      p_porcen       NUMBER;
      n_titula       NUMBER;
   BEGIN
      FOR c IN titulares LOOP
         -- miramos cuantos titulares tiene el contrato
         SELECT COUNT(1)
           INTO n_titula
           FROM presttitulares
          WHERE ctapres = pctapres;

         -- obtenemos el porcentaje por defecto
         IF n_titula = 1 THEN
            p_porcen := f_parproductos_v(psproduc, 'MIN_CONTRATO');
         ELSE
            p_porcen := 0;
         END IF;

         BEGIN
            -- Bug 11301 - APD - 22/10/2009 - se aNade la columna FALTA en el insert
            INSERT INTO estpresttitulares
                        (ctapres, norden, snip, pporcen, falta)
                 VALUES (c.ctapres, c.norden, c.snip, p_porcen, c.falta);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;   -- ya estaban no modificamos los datos
            WHEN OTHERS THEN
               RETURN 151554;   --error al insertar en titulares
         END;
      END LOOP;

      RETURN 0;
   END f_inserta_estpresttitulares;

   FUNCTION f_inserta_vinculado(pctapres IN VARCHAR2, psseguro IN NUMBER, pporcent IN NUMBER)
      RETURN NUMBER IS
      vnmovimi       estprestamoseg.nmovimi%TYPE;
      f_efecto       DATE;
      num_error      NUMBER;   -- Bug 11301 - APD - 22/10/2009
      v_falta        DATE;   -- Bug 11301 - APD - 22/10/2009
   BEGIN
      -- Bug 11301 - APD - 22/10/2009 - se busca la falta del prestamo para aNadirla
      -- al insert de la tabla estprestamoseg
      num_error := pac_prestamos.f_fecha_ult_prest(pctapres, v_falta);

      IF num_error <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_inserta_vinculado', 1,
                     'Error en pac_prestamos.f_fecha_ult_prest',
                     num_error || ' - ' || f_axis_literales(num_error));
         RETURN 151456;
      END IF;

      BEGIN
         -- Bug 11301 - APD - 22/10/2009 - se aNade la columna FALTA en el insert
         INSERT INTO estprestamoseg
                     (ctapres, sseguro, nmovimi, finiprest, ffinprest, pporcen, falta)
              VALUES (pctapres, psseguro, vnmovimi, TRUNC(f_sysdate), NULL, pporcent, v_falta);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151456;   -- Error al insertar la poliza vinculada
      END;

      BEGIN
         SELECT fefecto
           INTO f_efecto
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151341;   -- Error al calcular la fecha de vencimiento
      END;

      --obetenmos la duración del contrato
      UPDATE estseguros
         SET nduraci = f_fvencim_vinculados(pctapres, f_efecto)
       WHERE sseguro = psseguro;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 151456;
   END f_inserta_vinculado;

   FUNCTION f_valida_poliza_prestamo(
      pctapres IN VARCHAR2,
      psperson IN NUMBER,   -- BUG13945:DRA:30/03/2010
      psseguro IN NUMBER)   -- BUG13945:DRA:30/03/2010
      RETURN NUMBER IS
      -- Bug 0012802 - 20/01/2010 - JMF
      -- s_sperson      per_personas.sperson%TYPE;
      num_err        NUMBER;
   BEGIN
      -- a)si es física solo puede tener una poliza como riesgo para ese contrato y que esté vigente
      -- b)si es jurídca no se valida ya que obligamos que informe el riesgo, si que harbra que validar en pantalla de riesgo

      /* BUG13945:DRA:29/03/2010:Inici
      BEGIN
         -- Bug 0012802 - 20/01/2010 - JMF
         SELECT sperson
           INTO s_sperson
           FROM per_personas
          WHERE sperson = psperson;  -- BUG13945:DRA:29/03/2010
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- esta persona aún no está en el sistema
            -- por tanto no tiene polizas.
            RETURN 0;
      END;
      BUG13945:DRA:29/03/2010:Fi */

      -- Miramos si la persona existe como riesgo en alguna poliza
      --vigente para el contrato en cuestion
      BEGIN
         SELECT COUNT(1)
           INTO num_err
           FROM riesgos r, prestamoseg p, seguros s
          WHERE sperson = psperson   -- BUG13945:DRA:29/03/2010
            AND p.ctapres = pctapres
            AND r.sseguro = p.sseguro
            AND s.sseguro = r.sseguro
            AND s.sseguro <> psseguro   -- BUG13945:DRA:30/03/2010
            AND(f_vigente(r.sseguro, NULL, f_sysdate) = 0
                OR s.csituac = 4
                   AND s.creteni NOT IN(3, 4))
            AND p.nmovimi = (SELECT MAX(nmovimi)   -- BUG 23681 - FAL - 18/09/2012
                               FROM prestamoseg
                              WHERE sseguro = p.sseguro);
      END;

      IF num_err > 0 THEN
         RETURN 151485;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_valida_poliza_vin', 1,
                     'pctapres: ' || pctapres || ' - psperson: ' || psperson, SQLERRM);
         RETURN 151486;   -- No se ha encontrado el contrato vinculado
   END f_valida_poliza_prestamo;

   FUNCTION f_valida_risc_vin(psproduc IN NUMBER, psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER;
      c_ctapres      VARCHAR2(20);
      s_ssegpol      estseguros.ssegpol%TYPE;
   BEGIN
      IF f_prod_vinc(psproduc) = 1 THEN   -- Si es un producto de vinculados
         BEGIN
            SELECT ctapres
              INTO c_ctapres
              FROM estprestamoseg
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 151486;
         --No se ha encontrado el contrato vinculado a la poliza
         END;

         --obtenemos el seguro real para o contarlo
         BEGIN
            SELECT ssegpol
              INTO s_ssegpol
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
                -- si no troba cap seguros a estseguros es més correcte que
               --doni el error de persona existente,
               RETURN 151485;
         --Persona existe como asegurado en otra poliza de para el contrato
         END;

         BEGIN
            SELECT COUNT(1)
              INTO num_err
              FROM riesgos r, prestamoseg p, seguros s
             WHERE sperson = psperson
               AND s.sseguro = r.sseguro
               AND(f_vigente(r.sseguro, NULL, f_sysdate) = 0
                   OR s.csituac = 4
                      AND s.creteni NOT IN(3, 4))
               AND p.sseguro = r.sseguro
               AND p.ctapres = c_ctapres
               AND p.sseguro <> s_ssegpol
               AND p.nmovimi = (SELECT MAX(nmovimi)   -- BUG 23681 - FAL - 18/09/2012
                                  FROM prestamoseg
                                 WHERE ctapres = c_ctapres
                                   AND sseguro = p.sseguro
                                   AND nriesgo = r.nriesgo);
         END;

         IF num_err > 0 THEN
            RETURN 151485;
         --Persona existe como asegurado en otra poliza de para el contrato
         END IF;
      END IF;

      RETURN 0;
   END f_valida_risc_vin;

   FUNCTION f_obtener_estcap_vin(psseguro IN NUMBER, picapital OUT NUMBER)
      RETURN NUMBER IS
      c_ctapres      VARCHAR2(15);
      p_porcen       estpresttitulares.pporcen%TYPE;
   BEGIN
      BEGIN
         SELECT ctapres
           INTO c_ctapres
           FROM estprestamoseg
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151486;   --no se ha encontrado el contratado vinculado
      END;

      --obtenemos el porcentaje del titular
      BEGIN
         SELECT pporcen
           INTO p_porcen
           FROM estpresttitulares
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 111785;   -- Falta informar el porcentaje
      END;

      BEGIN
         SELECT icapital *(p_porcen / 100)
           INTO picapital
           FROM prestcapitales
          WHERE ctapres = c_ctapres
            AND ffincap IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151487;   --capital del contratdo vinculado incoherente
      END;

      RETURN 0;
   END f_obtener_estcap_vin;

   FUNCTION f_obtener_titular(psseguro IN NUMBER, pctapres IN NUMBER)
      RETURN NUMBER IS
      n_norden       presttitulares.norden%TYPE;
   BEGIN
      -- función que dado un sseguro y ctapres retorna el norden de prestitulares
      -- Bug 0012802 - 20/01/2010 - JMF
      SELECT norden
        INTO n_norden
        FROM presttitulares p, tomadores t, per_personas x
       WHERE t.sseguro = psseguro
         AND t.sperson = x.sperson
         AND p.snip = x.snip
         AND p.ctapres = pctapres;

      RETURN n_norden;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END f_obtener_titular;

   FUNCTION f_duplicar_titular(pctapres IN VARCHAR2, psnip IN NUMBER)
      RETURN NUMBER IS
      n_norden       estpresttitulares.norden%TYPE;
      num_error      NUMBER;   -- Bug 11301 - APD - 22/10/2009
      v_falta        DATE;   -- Bug 11301 - APD - 22/10/2009
   BEGIN
      SELECT MAX(norden)
        INTO n_norden
        FROM estpresttitulares
       WHERE ctapres = pctapres;

      n_norden := NVL(n_norden, 0) + 1;
      -- Bug 11301 - APD - 22/10/2009 - se busca la falta del prestamo para aNadirla
      -- al insert de la tabla estprestamoseg
      num_error := pac_prestamos.f_fecha_ult_prest(pctapres, v_falta);

      IF num_error <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_duplicar_titular', 1,
                     'Error en pac_prestamos.f_fecha_ult_prest',
                     num_error || ' - ' || f_axis_literales(num_error));
         RETURN 151552;   -- No se ha podido dupluicar el titular
      END IF;

      -- Bug 11301 - APD - 22/10/2009 - se aNade la columna FALTA en el insert
      INSERT INTO estpresttitulares
                  (ctapres, norden, snip, pporcen, sseguro, falta)
           VALUES (pctapres, n_norden, psnip, 0, NULL, v_falta);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_duplicar_titular', 1,
                     'duplicar titular', SQLERRM);
         RETURN 151552;   -- No se ha podido dupluicar el titular
   END f_duplicar_titular;

   FUNCTION f_vincpolizas_productos(pctapres IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER IS
      n_prestamo     NUMBER;
      n_error        NUMBER;
   BEGIN
      -- Miramos si existe alguna póliza vigente que sea del mismo contrato, pero
      -- no sea del mismo producto
      SELECT COUNT(1)
        INTO n_prestamo
        FROM prestamoseg p, seguros s
       WHERE p.ctapres = pctapres
         AND p.sseguro = s.sseguro
         AND s.sproduc <> psproduc
         AND f_vigente(s.sseguro, NULL, f_sysdate) = 0;

      IF n_prestamo > 0 THEN
         n_error := 151575;
      -- Existen polizas vinculadas a este contrato de otro producto
      ELSE
         n_error := 0;
      END IF;

      RETURN n_error;
   END f_vincpolizas_productos;

   FUNCTION f_fvencim_vinculados(pctapres IN VARCHAR2, pfefecto IN DATE)
      RETURN NUMBER IS
      /*******************************************************************************
       Función que retorna la duración (nduraci) de un contrato en aNos.
      ********************************************************************************/
      f_fvencim      DATE;
   BEGIN
      IF pfefecto IS NULL THEN
         RETURN NULL;
      END IF;

      -- obtenemos la fecha de vencimiento del prestamo
      BEGIN
         SELECT fvencim
           INTO f_fvencim
           FROM prestcapitales
          WHERE ctapres = pctapres
            AND ffincap IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END;

      --
      RETURN CEIL(MONTHS_BETWEEN(f_fvencim, pfefecto) / 12);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_fvencim_vinculados;

   FUNCTION f_inicializar_modificacion(
      psseguro IN NUMBER,
      p_est_sseguro OUT NUMBER,
      pnmovimi OUT NUMBER,
      pcmodo IN VARCHAR2 DEFAULT NULL,
      ptform IN VARCHAR2 DEFAULT NULL,
      ptcampo IN VARCHAR2 DEFAULT '*')
      RETURN NUMBER IS
/******************************************************************************************
   psseguro: sseguro de la tabla SEGUROS

*******************************************************************************************/
      CURSOR est IS
         SELECT sseguro
           FROM estseguros
          WHERE ssegpol = psseguro;

      CURSOR risc(v_est_sseguro IN NUMBER) IS
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = v_est_sseguro;

      num_err        NUMBER;
      mens           VARCHAR2(2000);
      v_est_sseguro  estseguros.sseguro%TYPE;
      v_sproduc      estseguros.sproduc%TYPE;
      v_nmovimi      estgaranseg.nmovimi%TYPE;
      v_cactivi      estseguros.cactivi%TYPE;
      v_fefecto      DATE;
      vcont          NUMBER;
   BEGIN
      FOR c IN est LOOP
         pac_alctr126.borrar_tablas_est(c.sseguro);
      END LOOP;

      pac_alctr126.traspaso_tablas_seguros(psseguro, mens);

      IF mens IS NOT NULL THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_inicializar_modificacion', 1,
                     'Pac_Alctr126.traspaso_tablas_seguros (' || psseguro || ',' || mens
                     || ')',
                     mens);
         -- se deberá grabar en tab_error
         RETURN 105419;   --ERROR TRASPASO
      END IF;

      COMMIT;

      -- Averiguamos el sseguro de las tablas EST
      BEGIN
         SELECT MAX(sseguro), MAX(sproduc), MAX(cactivi)
           INTO v_est_sseguro, v_sproduc, v_cactivi
           FROM estseguros
          WHERE ssegpol = psseguro;

         SELECT fefecto
           INTO v_fefecto
           FROM seguros
          WHERE sseguro = psseguro;

         IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'NOTA_INFORMATIVA'), 0) = 0 THEN
            SELECT DISTINCT (nmovimi)
                       INTO v_nmovimi
                       FROM estgaranseg
                      WHERE sseguro = v_est_sseguro;
         ELSE
            SELECT COUNT(nmovimi)
              INTO vcont
              FROM estgaranseg
             WHERE sseguro = v_est_sseguro;

            IF vcont > 0 THEN
               SELECT DISTINCT (nmovimi)
                          INTO v_nmovimi
                          FROM estgaranseg
                         WHERE sseguro = v_est_sseguro;
            ELSE
               v_nmovimi := 1;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 101919;   --error al leer datos de la tabla seguros
      END;

      FOR c_risc IN risc(v_est_sseguro) LOOP
         -- Bug 9699 - APD - 23/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
         num_err :=
            pk_nueva_produccion.f_garanpro_estgaranseg
                                                (v_est_sseguro, c_risc.nriesgo, v_nmovimi,
                                                 v_sproduc, v_fefecto,
                                                 pac_seguros.ff_get_actividad(v_est_sseguro,
                                                                              c_risc.nriesgo,
                                                                              'EST'));
      -- Bug 9699 - APD - 23/04/2009 - fin
      END LOOP;

      UPDATE estclaubenseg
         SET cobliga = 1
       WHERE sseguro = v_est_sseguro;

      IF pcmodo = 'MODIF_PROP' THEN
         --ini bug 29229#c160430 JDS
         IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
            AND pac_seguros.f_get_escertifcero(NULL, psseguro) = 1 THEN
            BEGIN
               -- Tomamos la max fecha de efecto de los diferentes certificados.
               -- Los suplelemntos anulados delos certificados no los tenemos que contar.
               SELECT MAX(m.fefecto)
                 INTO v_fefecto
                 FROM movseguro m, seguros s
                WHERE s.npoliza = (SELECT npoliza
                                     FROM seguros
                                    WHERE sseguro = psseguro)
                  AND s.ncertif <> 0
                  AND s.sseguro = m.sseguro
                  AND s.csituac <> 2
                  AND m.cmovseg NOT IN(52);
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN SQLCODE;
            END;
         ELSE
            SELECT MAX(m.fefecto)
              INTO v_fefecto
              FROM movseguro m, seguros s
             WHERE s.sseguro = psseguro
               AND s.sseguro = m.sseguro
               AND s.csituac <> 2
               AND m.cmovseg NOT IN(52);
         END IF;

         --fi bug 29229#c160430 JDS
         num_err := pk_suplementos.f_inicializar_fechas(v_est_sseguro, v_nmovimi, v_sproduc,
                                                        v_fefecto, pcmodo);
         num_err := pk_suplementos.f_permite_anadir_suplementos(v_est_sseguro, UPPER(f_user),
                                                                pcmodo, ptform, ptcampo);
       -- 29358/10948 - 30/01/2014
       /*

      IF num_err <> 0 THEN   --no hay suplementos
           p_tab_error(f_sysdate, f_user, 'PK_NUEVA_PRODUCCION.f_inicializar_modificacion',
                       0,
                       'Pk_Suplementos.f_permite_anadir_suplementos (' || v_est_sseguro
                       || ',' || UPPER(f_user) || ',' || pcmodo || ',' || ptform || ','
                       || ptcampo || ')',
                       'num_error(' || num_err || ') RETURN 151391');

           pac_alctr126.borrar_tablas_est(v_est_sseguro);
           RETURN 151391;   -- suplementos incompatibles
        END IF;
        */
      END IF;

      p_est_sseguro := v_est_sseguro;
      pnmovimi := v_nmovimi;
      RETURN 0;
   END f_inicializar_modificacion;

   FUNCTION f_grabar_alta_poliza(psseguro IN NUMBER, pnempleado IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      /******************************************************************************************
         funcion que graba una póliza una vez que ya estamos en la pantalla final con
        todos los datos validados

      *******************************************************************************************/
      reg_seg        estseguros%ROWTYPE;
      num_err        NUMBER;
      v_npoliza      NUMBER := NULL;
      v_nsolici      NUMBER;
      error          VARCHAR2(3000);
      prim_total     NUMBER;
      v_fcancel      DATE;
      meses_prop     NUMBER;
      v_pinttec      NUMBER;
      v_npoliza_prefijo NUMBER;
      v_npoliza_cnv  NUMBER;   -- BUG15617:DRA:23/08/2010
      v_npoliza_ini  VARCHAR2(15);   -- BUG15617:DRA:23/08/2010
   BEGIN
      -- obtenemos datos del seguro
      SELECT *
        INTO reg_seg
        FROM estseguros
       WHERE sseguro = psseguro;

      num_err := pac_clausulas.f_ins_clausulas(psseguro, NULL, 1, reg_seg.fefecto);
      -- traspasamos a las tablas de SEGUROS
      pac_alctr126.traspaso_tablas_est(psseguro, reg_seg.fefecto, NULL, error, 'ALCTR126',
                                       NULL, 1, NULL);

      IF error IS NOT NULL THEN
         p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_grabar_alta_poliza', 1,
                     'traspaso tablas sseguro =' || psseguro || ' ssegpol ='
                     || reg_seg.ssegpol,
                     error);
         RETURN 105419;   -- error traspaso
      END IF;

      -- se borran las tablas EST
      pac_alctr126.borrar_tablas_est(psseguro);

      -- informamos el número de empleado en movseguro
      IF pnempleado IS NOT NULL THEN
         BEGIN
            UPDATE movseguro
               SET nempleado = pnempleado
             WHERE sseguro = reg_seg.ssegpol
               AND nmovimi = 1;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_grabar_alta_poliza', 2,
                           'error al grabar el nempleado  ssegpol =' || reg_seg.ssegpol
                           || ' nempleado =' || pnempleado,
                           SQLERRM);
               RETURN 105235;   -- error al modificar movseguro
         END;
      END IF;

      -- Averiguamos el iprianu total
      prim_total := f_segprima(reg_seg.ssegpol, reg_seg.fefecto);

      -- Damos el número de póliza o número de solicitud
      IF NVL(f_parproductos_v(reg_seg.sproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 THEN
         -- eL NÚMERO DE PÓLIZA SE DA EN LA EMISIÓN Y AHORA ASIGNAMOS NÚMERO DE SOLICITUD
         IF reg_seg.nsolici IS NULL THEN   -- es la primera vez que grabamos
            -- BUG 0019332 - 30/08/2011 - JMF
            v_nsolici := pac_propio.f_numero_solici(reg_seg.cempres, reg_seg.cramo);
         END IF;
      ELSE
         -- asiganamos ahora el número de póliza
         IF reg_seg.npoliza = reg_seg.ssegpol THEN
            -- BUG15617:DRA:23/08/2010:Inici
            v_npoliza_cnv := NVL(f_parproductos_v(reg_seg.sproduc, 'NPOLIZA_CNVPOLIZAS'), 0);

            IF v_npoliza_cnv IN(1, 2) THEN
               -- BUG16372:DRA:19/10/2010:Inici
               v_npoliza_ini := f_npoliza(NULL, reg_seg.ssegpol);

               IF LENGTH(v_npoliza_ini) > 8 THEN
                  num_err := 9901434;   -- El número de pòlissa ha de ser numÃ¨ric i de 8 dígits com a màxim
               END IF;

               BEGIN
                  v_npoliza := TO_NUMBER(v_npoliza_ini);
               EXCEPTION
                  WHEN OTHERS THEN
                     num_err := 9901434;   -- El número de pòlissa ha de ser numÃ¨ric i de 8 dígits com a màxim
               END;

               IF num_err <> 0 THEN
                  p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_grabar_alta_poliza',
                              3,
                              'error al obtener npolissa_ini  ssegpol =' || reg_seg.ssegpol
                              || ', npolissa_ini=' || v_npoliza_ini,
                              f_axis_literales(num_err, f_usu_idioma));
                  RETURN num_err;
               END IF;

               -- BUG16372:DRA:19/10/2010:Fi
               IF v_npoliza IS NULL
                  AND v_npoliza_cnv = 2 THEN
                  -- El numero de póliza inicial debe estar informado
                  num_err := 120006;
                  p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_grabar_alta_poliza',
                              4,
                              'error al obtener npolissa_ini  ssegpol =' || reg_seg.ssegpol
                              || ', npolissa_ini=' || v_npoliza_ini,
                              f_axis_literales(num_err, f_usu_idioma));
                  RETURN num_err;
               END IF;
            END IF;

            IF v_npoliza IS NULL
               AND num_err = 0 THEN
               -- Bug 9720 - APD - 28/04/2009 - Antes de llamar a la función f_contador se deberá verificar el parproducto
               -- 'NPOLIZA_PREFIJO' devuelva un valor. En caso de que no esté informado se llamará a la f_contador
               -- con el cramo (como se está haciendo en la actualidad), en caso contrario se deberá llamar con el
               -- resultado del parproducto
               v_npoliza_prefijo := f_parproductos_v(reg_seg.sproduc, 'NPOLIZA_PREFIJO');

               IF v_npoliza_prefijo IS NOT NULL THEN
                  reg_seg.cramo := v_npoliza_prefijo;
               END IF;

               -- Bug 9720 - APD - 28/04/2009 - Fin

               -- es la primera vez que grabamos

               -- BUG 17008 - 15/12/2010 - JMP - Llamar a PAC_PROPIO.F_CONTADOR2 para la generación del nÂº de póliza
               v_npoliza := pac_propio.f_contador2(reg_seg.cempres, '02', reg_seg.cramo);
            END IF;
         -- BUG15617:DRA:23/08/2010:Fi
         END IF;
      END IF;

      IF reg_seg.fcancel IS NULL THEN
         --BUG 15304 - 09/07/2010 - JRB - Se inserta la fecha de cancelacion de la propuesta a partir de DIAS_PROPOST_VALIDA
         IF NVL(f_parproductos_v(reg_seg.sproduc, 'DIAS_PROPOST_VALIDA'), 0) > 0 THEN
            v_fcancel := reg_seg.fefecto
                         + f_parproductos_v(reg_seg.sproduc, 'DIAS_PROPOST_VALIDA');
         ELSE
            -- si no está informada la fecha de cancelación de la propuesta
            meses_prop := NVL(f_parproductos_v(reg_seg.sproduc, 'MESES_PROPOST_VALIDA'), 0);

            IF meses_prop > 0 THEN
               /*v_fcancel := TO_DATE('01'
                                    || TO_CHAR(ADD_MONTHS(f_sysdate, meses_prop + 1), 'mmyyyy'),
                                    'ddmmyyyy');*/
               v_fcancel := ADD_MONTHS(reg_seg.fefecto, meses_prop);
            ELSE
               v_fcancel := NULL;
            END IF;
         END IF;
      END IF;

      -- modificamos los valores del seguro
      BEGIN
         UPDATE seguros
            SET iprianu = prim_total,
                npoliza = NVL(v_npoliza, reg_seg.npoliza),
                nsolici = NVL(v_nsolici, reg_seg.nsolici),
                fcancel = NVL(v_fcancel, reg_seg.fcancel)
          WHERE sseguro = reg_seg.ssegpol;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pk_nueva_produccion.f_grabar_alta_poliza', 2,
                        'error al modificar seguros  ssegpol =' || reg_seg.ssegpol, SQLERRM);
            RETURN 102361;   -- error al modificar la tabla seguros
      END;

      RETURN 0;
   END f_grabar_alta_poliza;

   FUNCTION f_calculo_capital_calculado(
      pfecha IN DATE,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      porigen IN NUMBER,
      pcapital OUT NUMBER)   -- 0.- sol, 1.- est, 2.- SEG
      RETURN NUMBER IS
      v_sproduc      estseguros.sproduc%TYPE;
      v_ctipcap      garanpro.ctipcap%TYPE;
      clav           NUMBER;
      num_err        NUMBER;
      v_cramo        estseguros.cramo%TYPE;
      v_cmodali      estseguros.cmodali%TYPE;
      v_ctipseg      estseguros.ctipseg%TYPE;
      v_ccolect      estseguros.ccolect%TYPE;
   BEGIN
      --  Comprobamos que el capital es calculado
      BEGIN
         SELECT s.sproduc, ctipcap, s.cramo, s.cmodali, s.ctipseg, s.ccolect
           INTO v_sproduc, v_ctipcap, v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM estseguros s, garanpro g
          WHERE sseguro = psseguro
            AND s.sproduc = g.sproduc
            AND g.cgarant = pcgarant
            AND g.cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT s.sproduc, ctipcap
              INTO v_sproduc, v_ctipcap
              FROM estseguros s, garanpro g
             WHERE sseguro = psseguro
               AND s.sproduc = g.sproduc
               AND g.cgarant = pcgarant
               AND g.cactivi = 0;
         WHEN OTHERS THEN
            RETURN 101903;
      END;

      IF v_ctipcap <> 5 THEN
         RETURN 112349;
      END IF;

      -- Calculamos la clave de la fórmula
      num_err := pac_tarifas.f_clave(pcgarant, v_cramo, v_cmodali, v_ctipseg, v_ccolect,
                                     pcactivi, 'ICAPCAL', clav);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      num_err := pac_calculo_formulas.calc_formul(pfecha, v_sproduc, pcactivi, pcgarant,
                                                  pnriesgo, psseguro, clav, pcapital, pnmovimi,
                                                  NULL, 1);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_calculo_capital_calculado;

   FUNCTION f_obtener_fvencim_nduraci(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcduraci IN NUMBER,
      pnduraci IN OUT NUMBER,
      pfvencim IN OUT DATE)
      RETURN NUMBER IS
      v_nduraci      NUMBER;
      v_fvencim      DATE;
      v_cdurmin      productos.cdurmin%TYPE;
      v_nvtomin      productos.nvtomin%TYPE;
      v_fnacimi      DATE;
      v_sproduc      estseguros.sproduc%TYPE;
   BEGIN
      v_nduraci := pnduraci;
      v_fvencim := pfvencim;

      IF pcduraci = 0 THEN   --anual renovable
         v_fvencim := NULL;
      ELSIF pcduraci = 1 THEN   -- anos
         v_fvencim := ADD_MONTHS(pfefecto, v_nduraci * 12);
      ELSIF pcduraci = 2 THEN   --meses
         v_fvencim := ADD_MONTHS(pfefecto, v_nduraci);
      ELSIF pcduraci = 3 THEN   --hasta vencimiento
         IF pfvencim IS NOT NULL THEN
            v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
         END IF;
      ELSIF pcduraci = 5 THEN   -- anos más un día
         v_fvencim := ADD_MONTHS(pfefecto, v_nduraci * 12) + 1;
      END IF;

      IF v_fvencim IS NULL THEN
         -- no ha sido calculada hasta ahora calculamos la duración mínima
         BEGIN
            SELECT cdurmin, nvtomin
              INTO v_cdurmin, v_nvtomin
              FROM estseguros e, productos p
             WHERE e.sproduc = p.sproduc
               AND e.sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 101919;   -- eror al leer datos de la tabla seguros
         END;

         IF v_cdurmin = 0 THEN   -- anos
            v_fvencim := ADD_MONTHS(pfefecto, v_nvtomin * 12);
            v_nduraci := v_nvtomin;
         ELSIF v_cdurmin = 1 THEN   --meses
            v_fvencim := ADD_MONTHS(pfefecto, v_nvtomin);
            v_nduraci := v_nvtomin;
         ELSIF v_cdurmin = 2 THEN   --dias
            v_fvencim := pfefecto + v_nvtomin;
            v_nduraci := v_nvtomin;
         ELSIF v_cdurmin = 3 THEN   -- meses más 1 día
            v_fvencim := ADD_MONTHS(pfefecto, v_nvtomin) + 1;
            v_nduraci := v_nvtomin;
         ELSIF v_cdurmin = 4 THEN   -- fecha primer período
            --- caso concreto de caixa, de momento devolvemos null
            v_fvencim := NULL;
         ELSIF v_cdurmin = 5 THEN   -- desde/hasta edad
            -- Bug 0012802 - 20/01/2010 - JMF
            SELECT MIN(fnacimi)
              INTO v_fnacimi
              FROM estriesgos e, estper_personas p
             WHERE e.sseguro = psseguro
               AND p.sperson = e.sperson;

            v_fvencim := ADD_MONTHS(v_fnacimi, 12 * v_nvtomin);
            v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);

            BEGIN
               SELECT sproduc
                 INTO v_sproduc
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 101919;   -- error al leer de la tabla SEGUROS
            END;

            IF NVL(f_parproductos_v(v_sproduc, 'DIA_INICIO_01'), 0) IN(1, 3) THEN
               -- la fecha de vencimiento será el 1 del mes siguiente
               v_fvencim := TO_DATE('01' || TO_CHAR((LAST_DAY(v_fvencim) + 1), 'mmyyyy'),
                                    'ddmmyyyy');
               v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
            ELSIF NVL(f_parproductos_v(v_sproduc, 'DIA_INICIO_01'), 0) IN(2, 4) THEN
               -- la fecha de vencimiento será el 1 del mes en curso
               v_fvencim := TO_DATE('01' || TO_CHAR(v_fvencim, 'mmyyyy'), 'ddmmyyyy');
               v_nduraci := ROUND((MONTHS_BETWEEN(v_fvencim, pfefecto) / 12), 2);
            END IF;
         END IF;
      END IF;

      pfvencim := v_fvencim;
      pnduraci := v_nduraci;
      RETURN 0;
   END f_obtener_fvencim_nduraci;

   --(JAS)11.12.2007 - Gestió de preguntes per pòlissa
   FUNCTION f_valida_pregun_poliza(
      p_in_sseguro IN seguros.sseguro%TYPE,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa OUT VARCHAR2)
      RETURN NUMBER IS
      w_ret          NUMBER := 0;
      v_nerror       NUMBER(10);
      v_tpregun      preguntas.tpregun%TYPE;

      CURSOR c_existpreg(
         pc_in_sseguro IN estpregunseg.sseguro%TYPE,
         pc_in_sproduc IN pregunpro.sproduc%TYPE,
         pisaltacol IN NUMBER,
         pissimul IN NUMBER) IS
         --  SELECT 1
         SELECT cpregun
           FROM (SELECT cpregun
                   FROM pregunpro p
                  WHERE p.sproduc = pc_in_sproduc
                    AND p.cpreobl = 1   --obligatorias
                    AND p.cpretip <> 2
                    -- AND p.cofersn <> 2
                       -- jlb
                    AND((p.cofersn <> 2
                         AND pissimul = 0)
                        OR(p.cofersn = 1
                           AND pissimul = 1))
                    -- jlb
                    AND p.cnivel = 'P'
                    AND((p.visiblecol = 1
                         AND pisaltacol = 1)
                        OR(pisaltacol = 0
                           AND p.visiblecert = 1))   -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
                 MINUS
                 SELECT cpregun
                   FROM estpregunpolseg
                  WHERE sseguro = pc_in_sseguro)
          WHERE ROWNUM = 1;

      tipo           NUMBER;
      campo          VARCHAR2(50);
      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementación para el alta de colectivos
      v_isaltacol    NUMBER;
      -- Fin Bug 16106
        -- jlb
      vissimul       NUMBER := 0;
   BEGIN
      -- jlb -- no deberia acceder a esta variable, pero por rendimiento y es pantalla o cargas estará informada
      -- no toco lo de abajo para no afectar
      IF pac_iax_produccion.isaltacol THEN
         isaltacol := TRUE;
      ELSE
         isaltacol := FALSE;
      END IF;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementación para el alta de colectivos
      IF isaltacol THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      -- jlb
      IF pac_iax_produccion.issimul THEN
         vissimul := 1;
      END IF;

      -- Fin Bug 16106
      <<l_existpreg>>
      FOR reg_existpreg IN c_existpreg(p_in_sseguro, psproduc, v_isaltacol, vissimul) LOOP
         tipo := 5;
         campo := NULL;
         w_ret := 120307;
         v_nerror := f_despregunta(reg_existpreg.cpregun, f_usu_idioma, v_tpregun);
         pmensa := f_axis_literales(w_ret, f_usu_idioma) || '.' || reg_existpreg.cpregun
                   || '-' || v_tpregun;
      END LOOP l_existpreg;

      RETURN w_ret;
   END f_valida_pregun_poliza;

   /*************************************************************************
   FUNCTION f_validacion_primaminfrac
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   param out p_prima : prima anual
   return             : NUMBER
   *************************************************************************/
   FUNCTION f_validacion_primaminfrac(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pprima OUT NUMBER)
      RETURN NUMBER IS
      v_iprianu      estgaranseg.iprianu%TYPE;
      v_cforpag      estseguros.cforpag%TYPE;
      v_ipminfra     productos.ipminfra%TYPE;
   BEGIN
      BEGIN
         SELECT ipminfra
           INTO v_ipminfra
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_ipminfra := NULL;
      END;

      IF v_ipminfra IS NOT NULL THEN
         BEGIN
            SELECT cforpag
              INTO v_cforpag
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_cforpag := NULL;
         END;

         BEGIN
            SELECT SUM(iprianu)
              INTO v_iprianu
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_iprianu := NULL;
         END;

         -- BUG 9513 - 01/04/2009 - LPS - CEM - Validación de prima mínima
         pprima := NVL(v_ipminfra, 0);

         -- FI BUG 9513 - 01/04/2009 - LPS - CEM - Validación de prima mínima
         IF v_cforpag IS NOT NULL
            AND v_iprianu IS NOT NULL THEN
            IF v_cforpag NOT IN(0, 1) THEN
               IF v_ipminfra >(v_iprianu / v_cforpag) THEN
                  RETURN 9001117;
               END IF;
            END IF;
         ELSE
            RETURN 9001117;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_validacion_primaminfrac;

   /*************************************************************************
   FUNCTION f_validacion_primamin
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   param out p_prima : prima anual
   return             : NUMBER
   *************************************************************************/
   FUNCTION f_validacion_primamin(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pprima OUT NUMBER)
      RETURN NUMBER IS
      v_iprianu      estgaranseg.iprianu%TYPE;
      v_iprimin      productos.iprimin%TYPE;
      v_cforpag      estseguros.cforpag%TYPE;
      v_ipminfra     productos.ipminfra%TYPE;
   BEGIN
      BEGIN
         -- Bug 100113 - 18/05/2009 - RSC - Ajustes de Flexilife Nueva Emisión
         -- Antes: SELECT ipminfra, iprimin
         SELECT iprimin
           INTO v_iprimin
           FROM productos
          WHERE sproduc = psproduc;
      -- Fin Bug 100113
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_iprimin := NULL;
      END;

      -- Bug 100113 - 18/05/2009 - RSC - Ajustes de Flexilife Nueva Emisión
      -- Antes: IF v_ipminfra IS NOT NULL THEN
      IF v_iprimin IS NOT NULL THEN
         BEGIN
            SELECT cforpag
              INTO v_cforpag
              FROM estseguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_cforpag := NULL;
         END;

         BEGIN
            SELECT SUM(iprianu)
              INTO v_iprianu
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_iprianu := NULL;
         END;

         -- BUG 9513 - 01/04/2009 - LPS - CEM - Validación de prima mínima
         pprima := NVL(v_iprimin, 0);

         IF v_cforpag IS NOT NULL
            AND v_iprianu IS NOT NULL THEN
            IF v_iprianu <= v_iprimin THEN
               RETURN 800760;
            END IF;
         ELSE
            RETURN 800760;
         END IF;
      -- FI BUG 9513 - 01/04/2009 - LPS - CEM - Validación de prima mínima
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END f_validacion_primamin;

   -- BUG9216:DRA:23-02-2009:Creamos la función que Comprueba que alguna garantia básica haya sido seleccionada
   /*************************************************************************
       FUNCTION f_comprueba_basicos
       Comprueba que alguna garantia básica haya sido seleccionada
       param in psseguro  : código del seguro
       param in pssolici  : código de la solicitud
       param in pnriesgo  : numero de riesgo
       param in psproduc  : código del producto
       param in pcactivi  : código de la actividad
       param in pnmovimi  : numero de movimiento
       param in pnmovima  : numero de movimiento de alta
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_comprueba_basicos(
      psseguro IN NUMBER,
      pssolici IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER AS
      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      CURSOR c_garan(
         pc_in_sproduc IN garanpro.sproduc%TYPE,
         pc_in_cactivi IN garanpro.cactivi%TYPE) IS
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = pc_in_sproduc
            AND cactivi = pc_in_cactivi
            AND cbasica = 1
         UNION
         SELECT cgarant
           FROM garanpro
          WHERE sproduc = pc_in_sproduc
            AND cactivi = 0
            AND cbasica = 1
            AND NOT EXISTS(SELECT cgarant
                             FROM garanpro
                            WHERE sproduc = pc_in_sproduc
                              AND cactivi = pc_in_cactivi
                              AND cbasica = 1);

      -- Bug 9699 - APD - 23/04/2009 - Fin

      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      CURSOR c_est IS
         SELECT e.cgarant
           FROM estgaranseg e, garanpro g
          WHERE e.sseguro = psseguro
            AND e.nriesgo = pnriesgo
            AND e.cobliga = 1
            AND e.nmovimi = pnmovimi
            AND e.cgarant = g.cgarant
            AND g.sproduc = psproduc
            AND g.cactivi = pcactivi
            AND g.cbasica = 1
         UNION
         SELECT e.cgarant
           FROM estgaranseg e, garanpro g
          WHERE e.sseguro = psseguro
            AND e.nriesgo = pnriesgo
            AND e.cobliga = 1
            AND e.nmovimi = pnmovimi
            AND e.cgarant = g.cgarant
            AND g.sproduc = psproduc
            AND g.cactivi = 0
            AND g.cbasica = 1
            AND NOT EXISTS(SELECT e.cgarant
                             FROM estgaranseg e, garanpro g
                            WHERE e.sseguro = psseguro
                              AND e.nriesgo = pnriesgo
                              AND e.cobliga = 1
                              AND e.nmovimi = pnmovimi
                              AND e.cgarant = g.cgarant
                              AND g.sproduc = psproduc
                              AND g.cactivi = pcactivi
                              AND g.cbasica = 1);

      -- Bug 9699 - APD - 23/04/2009 - Fin

      -- Bug 9699 - APD - 23/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a GARANPRO para la actividad cero
      CURSOR c_sol(
         pc_in_ssolicit IN solgaranseg.ssolicit%TYPE,
         pc_in_nriesgo IN solgaranseg.nriesgo%TYPE,
         pc_in_sproduc IN garanpro.sproduc%TYPE,
         pc_in_cactivi IN garanpro.cactivi%TYPE) IS
         SELECT e.cgarant
           FROM solgaranseg e, garanpro g
          WHERE e.ssolicit = pc_in_ssolicit
            AND e.nriesgo = pc_in_nriesgo
            AND e.cobliga = 1
            AND e.cgarant = g.cgarant
            AND g.sproduc = pc_in_sproduc
            AND g.cactivi = pc_in_cactivi
            AND g.cbasica = 1
         UNION
         SELECT e.cgarant
           FROM solgaranseg e, garanpro g
          WHERE e.ssolicit = pc_in_ssolicit
            AND e.nriesgo = pc_in_nriesgo
            AND e.cobliga = 1
            AND e.cgarant = g.cgarant
            AND g.sproduc = pc_in_sproduc
            AND g.cactivi = 0
            AND g.cbasica = 1
            AND NOT EXISTS(SELECT e.cgarant
                             FROM solgaranseg e, garanpro g
                            WHERE e.ssolicit = pc_in_ssolicit
                              AND e.nriesgo = pc_in_nriesgo
                              AND e.cobliga = 1
                              AND e.cgarant = g.cgarant
                              AND g.sproduc = pc_in_sproduc
                              AND g.cactivi = pc_in_cactivi
                              AND g.cbasica = 1);

      -- Bug 9699 - APD - 23/04/2009 - Fin
      vres           NUMBER;
      vgarant        estgaranseg.cgarant%TYPE;
      ptablas        VARCHAR2(16);
   BEGIN
      ptablas := NVL(global_modo, 'EST');

      OPEN c_garan(psproduc, pcactivi);

      FETCH c_garan
       INTO vgarant;

      -- Si no hay garantias básicas es correcto
      IF (c_garan%ROWCOUNT = 0) THEN
         vres := 0;
      ELSE
         IF (ptablas = 'EST') THEN
            OPEN c_est;

            FETCH c_est
             INTO vgarant;

            IF (c_est%NOTFOUND) THEN
               vres := 102980;
            END IF;

            CLOSE c_est;
         ELSIF(ptablas = 'SOL') THEN
            OPEN c_sol(pssolici, pnriesgo, psproduc, pcactivi);

            FETCH c_sol
             INTO vgarant;

            IF (c_sol%NOTFOUND) THEN
               vres := 102980;
            END IF;

            CLOSE c_sol;
         END IF;
      END IF;

      CLOSE c_garan;

      RETURN NVL(vres, 0);
   END f_comprueba_basicos;

   -- BUG9523:DRA:18-03-2009
   /*************************************************************************
       FUNCTION f_calcula_nrenova
       Calcula el valor del campo NRENOVA de la tabla SEGUROS
       param in psseguro  : código del seguro
       param in pfecha    : fecha de efecto
       param out pnrenova : dia de renovacion
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_calcula_nrenova(psseguro IN NUMBER, pfecha IN DATE, pnrenova OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
                     := 'psseguro=' || psseguro || ' pfecha=' || TO_CHAR(pfecha, 'dd/mm/yyyy');
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.f_calcula_nrenova';
      vctipefe       NUMBER;
      v_fecha        DATE;
      vnrenova       NUMBER;
   BEGIN
      SELECT p.ctipefe, p.nrenova
        INTO vctipefe, vnrenova
        FROM productos p, seguros s
       WHERE p.sproduc = s.sproduc
         AND s.sseguro = psseguro;

      vpasexec := 2;

      IF vctipefe = 1 THEN
         pnrenova := vnrenova;
      ELSIF vctipefe = 2 THEN
         IF TO_CHAR(pfecha, 'dd') = 1 THEN
            v_fecha := pfecha;
         ELSE
            v_fecha := ADD_MONTHS(pfecha, 1);
         END IF;

         vpasexec := 3;
         pnrenova := TO_CHAR(v_fecha, 'mm') || '01';
      ELSIF vctipefe = 3 THEN
         vpasexec := 4;
         pnrenova := TO_CHAR(pfecha, 'mm') || '01';
      ELSE
         vpasexec := 5;
         pnrenova := TO_CHAR(pfecha, 'mmdd');
      END IF;

      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_calcula_nrenova;

   -- BUG9496:17/03/2009:DRA:Validem que estiguin contestades les preg. obligatories:Inici
   /*************************************************************************
       FUNCTION f_valida_pregun_garant
       Comprueba que la garantia tenga respondidas las preg. obligatorias
       param in psseguro  : código del seguro
       param in pnriesgo  : numero de riesgo
       param in pnmovimi  : numero de movimiento
       param in psproduc  : código del producto
       param in pcactivi  : código de la actividad
       param in pcgarant  : código de la garantía
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_pregun_garant(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN estgaranseg.cgarant%TYPE DEFAULT NULL,
      pmensa OUT VARCHAR2)
      RETURN NUMBER IS
      ---- Actua de dos MODOS, si es modo simulación, sseguro es ssolicit
      ----
      -- Valida  si hay preguntas (de garantia) manuales obligatorias sin contestar
      -- Valor devuelto:
      --   0 - OK No existen respuestas pendientes
      -- 700072 - OK, pero existen preguntas pendientes
      --  <>0 - Error, devuelve codi literal

      -- Bug 27744 - dlF - 14-IV-2014 - Preguntas de garantias en simulacion.
      -- parametro SIMULACION --------------------------------------------------
      CURSOR c_prg_pend(
         pc_in_cgarant pregunprogaran.cgarant%TYPE,
         pc_in_sseguro estgaranseg.sseguro%TYPE,
         pisaltacol NUMBER,
         pnsimulacion NUMBER) IS
         SELECT r.cgarant, r.cpregun
           FROM pregunprogaran r
          WHERE cgarant IN(SELECT cgarant
                             FROM estgaranseg
                            WHERE sseguro = pc_in_sseguro
                              AND nmovimi = NVL(pnmovimi, 1)
                              AND nriesgo = NVL(pnriesgo, 1)
                              AND NVL(cobliga, 0) = 1
                              AND NVL(global_modo, 'EST') = 'EST'
                           UNION
                           SELECT cgarant
                             FROM solgaranseg
                            WHERE ssolicit = pc_in_sseguro
                              AND nriesgo = NVL(pnriesgo, 1)
                              AND NVL(cobliga, 0) = 1
                              AND NVL(global_modo, 'EST') = 'SOL')
            AND cpretip IN(1, 3)
            AND cgarant = NVL(pc_in_cgarant, cgarant)
            AND cpreobl = 1
-- Inicio IAXIS-3398 24/07/2019 Marcelo Ozawa            
            AND cmodo in ('T', 'N')
-- Fin IAXIS-3398 24/07/2019 Marcelo Ozawa            
            AND((cofersn IN(1, 2)
                 AND NVL(global_modo, 'EST') = 'SOL')
                OR(NVL(global_modo, 'EST') <> 'SOL'))
            -- Bug 27744 - dlF - 14-IV-2014 - Preguntas de garantias en simulacion.
            AND((r.cofersn <> 2
                 AND pnsimulacion = 0)
                OR(r.cofersn = 1
                   AND pnsimulacion = 1))
--fin BUG ----------------------------------------------------------
            AND sproduc = psproduc
            AND cactivi IN(pcactivi, 0)
            AND((r.visiblecol = 1
                 AND pisaltacol = 1)
                OR(pisaltacol = 0
                   AND r.visiblecert = 1))   -- Bug 17362 - APD - 01/02/2011 - Ajustes GROUPLIFE
            AND NOT EXISTS(SELECT 1
                             FROM estpregungaranseg x
                            WHERE (x.crespue IS NOT NULL
                                   OR x.trespue IS NOT NULL)
                              AND x.sseguro = pc_in_sseguro
                              AND x.nriesgo = NVL(pnriesgo, 1)
                              AND x.cpregun = r.cpregun
                              AND x.cgarant = r.cgarant
                              AND NVL(global_modo, 'EST') = 'EST'
                           UNION
                           SELECT 1
                             FROM solpregungaranseg x
                            WHERE (x.crespue IS NOT NULL
                                   OR x.trespue IS NOT NULL)
                              AND x.ssolicit = pc_in_sseguro
                              AND x.nriesgo = NVL(pnriesgo, 1)
                              AND x.cpregun = r.cpregun
                              AND x.cgarant = r.cgarant
                              AND NVL(global_modo, 'EST') = 'SOL'
                           UNION
                           SELECT 1
                             FROM estpregungaransegtab x
                            WHERE x.sseguro = pc_in_sseguro
                              AND x.nriesgo = NVL(pnriesgo, 1)
                              AND x.cpregun = r.cpregun
                              AND x.cgarant = r.cgarant
                              AND NVL(global_modo, 'EST') = 'EST')
            AND ROWNUM = 1;   -- només busca la primera

      w_ret          NUMBER(7) := 0;
      v_nerror       NUMBER;
      v_tpregun      preguntas.tpregun%TYPE;
      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementación para el alta de colectivos
      v_isaltacol    NUMBER;
   -- Fin Bug 16106
   BEGIN
      pmensa := NULL;

      -- Bug 16106 - RSC - 11/10/2010 - APR - Ajustes e implementación para el alta de colectivos
      IF isaltacol THEN
         v_isaltacol := 1;
      ELSE
         v_isaltacol := 0;
      END IF;

      -- Fin Bug 16106

      -- Bug 27744 - dlF - 14-IV-2014 - Preguntas de garantias en simulacion.
      -- pasamos el parametro SIMULACION.
      FOR reg IN c_prg_pend(pcgarant, psseguro, v_isaltacol,
                            SYS.DIUTIL.bool_to_int(pac_iax_produccion.issimul)) LOOP
         -- Existexen preguntes obligatorias no respostes
         w_ret := 120307;
         v_nerror := f_despregunta(reg.cpregun, global_usu_idioma, v_tpregun);

         IF pmensa IS NULL THEN
            pmensa := v_tpregun;
         ELSE
            pmensa := pmensa || ', ' || v_tpregun;
         END IF;
      END LOOP;

      RETURN w_ret;
   EXCEPTION
      WHEN OTHERS THEN
         pmensa := SQLERRM;
         RETURN 140999;
   END f_valida_pregun_garant;

   -- BUG9496:17/03/2009:DRA:Fi

   --BUG 9709 - 06/04/2009 - LPS - Validación del limite del % de crecimiento geométrico
   /*************************************************************************
       FUNCTION f_valida_limrevalgeom
       Comprueba el límite de valorización geométrica
       param in psproduc  : código del producto
       param in prevali   : porcentaje de revalorización
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_limrevalgeom(
      psproduc IN NUMBER,
      pprevali IN NUMBER,
      pplimrev OUT NUMBER,
      pcrevali IN NUMBER DEFAULT 2)
      RETURN NUMBER IS
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200) := 'psproduc=' || psproduc || 'pprevali=' || pprevali;
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.f_valida_limrevalgeom';
      vprevali       NUMBER;
      vcvalpar       NUMBER;
      vnumerr        NUMBER;
      -- Bug 19412/95066 - RSC - 19/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
      v_prevali      revaliprod_permite.prevali%TYPE;
      v_reval_permite NUMBER;
   -- Fin Bug 19412/95066
   BEGIN
      vpasexec := 2;
      vnumerr := NVL(f_parproductos(psproduc, 'LIM_REVAL_GEOM', vcvalpar), 0);

      IF pprevali > NVL(vcvalpar, 100)
         AND vnumerr = 0
         AND pprevali IS NOT NULL THEN
         pplimrev := vcvalpar;
         RETURN 151389;
      ELSE
         -- Bug 19412/95066 - RSC - 19/10/2011 - LCOL_T004: Completar parametrización de los productos de Vida Individual
         SELECT COUNT(*)
           INTO v_reval_permite
           FROM revaliprod_permite
          WHERE sproduc = psproduc
            AND crevali = pcrevali;

         IF v_reval_permite > 0 THEN
            BEGIN
               SELECT prevali
                 INTO v_prevali
                 FROM revaliprod_permite
                WHERE sproduc = psproduc
                  AND crevali = pcrevali
                  AND prevali = pprevali;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 9902490;
            END;
         END IF;

         -- Fin BUg 19412/95066
         RETURN 0;
      END IF;

      vpasexec := 3;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_valida_limrevalgeom;

   /*************************************************************************
       Valida dependencia entre padre - dependientes. Es decir, si el padre
       está seleccionada, alguna de las dependientes debe estar seleccionada.

       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param in  P_sproduc  : Código de Producto
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   -- Bug 10113 - 18/05/2009 - RSC - Ajustes FlexiLife nueva emisión
   FUNCTION f_valida_dependencia_basica(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      CURSOR garantias IS
         SELECT e.cgarant, g.ctipgar
           FROM estgaranseg e, estseguros s, garanpro g
          WHERE e.sseguro = psseguro
            AND s.cramo = g.cramo
            AND s.cmodali = g.cmodali
            AND s.ctipseg = g.ctipseg
            AND s.ccolect = g.ccolect
            AND e.cgarant = g.cgarant
            AND s.sproduc = g.sproduc
            AND e.sseguro = s.sseguro
            AND e.nriesgo = pnriesgo
            AND e.cobliga = 1
            AND NVL(f_pargaranpro_v(g.cramo, g.cmodali, g.ctipseg, g.ccolect, s.cactivi,
                                    g.cgarant, 'DEPENDIENTE_BASIC'),
                    0) = 1;

      num_err        NUMBER;
      e_cancela      EXCEPTION;
      e_cancela_pre  EXCEPTION;
      vnsesion       NUMBER;
      v_sproduc      productos.sproduc%TYPE;
      v_cgarant      garanpro.cgarant%TYPE;
      v_cgarantdep   garanpro.cgarant%TYPE;
      v_contadep     NUMBER;
      v_conta        NUMBER;
      v_depe         NUMBER;
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM estseguros
       WHERE sseguro = psseguro;

      --FOR regs IN cur_garanpro (v_sproduc) LOOP
      FOR regs IN garantias LOOP
         v_contadep := 0;

         SELECT COUNT(*)
           INTO v_depe
           FROM garanpro
          WHERE cgardep = regs.cgarant
            AND sproduc = v_sproduc;

         -- Si existen garantias dependientes validamos
         IF v_depe > 0 THEN
            FOR regs2 IN (SELECT *
                            FROM garanpro
                           WHERE sproduc = v_sproduc
                             AND cgardep = regs.cgarant) LOOP
               SELECT COUNT(*)
                 INTO v_conta
                 FROM estgaranseg
                WHERE sseguro = psseguro
                  AND nriesgo = pnriesgo
                  AND cgarant = regs2.cgarant
                  AND cobliga = 1;

               IF v_conta > 0 THEN
                  v_contadep := v_contadep + 1;
               END IF;
            END LOOP;

            IF v_contadep = 0 THEN
               num_err := 9001610;
               RAISE e_cancela;
            END IF;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_cancela THEN
         RETURN num_err;
   END f_valida_dependencia_basica;

-- Fin Bug 10113

   /*************************************************************************
       FUNCTION f_valida_siniestro
       Función para saber si se ha de mostrar o no una determinada garantía apartir del producto.
       param in ptabla: Tipo varchar2. Parámetro de entrada. Indica si va sobre las EST o las Reales.
       param in psseguro: Tipo numérico. Parámetro de entrada. Codigo del seguro
       param in pnriesgo: Tipo numérico. Parámetro de entrada. Indicador del riesgo
       param in pcgarant: Tipo numérico. Parámetro de entrada. Codigo de la garantía.
       return             : 1 se muestra la garantía
                            0 no se muestra

        Bug: 8947 - ICV - 02/06/2009
   *************************************************************************/
   FUNCTION f_validar_siniestro(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      v_cgarant      garanseg.cgarant%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT ssegpol
           INTO v_sseguro
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         v_sseguro := psseguro;
      END IF;

      --Comprobar si la garantía se ha anulado por un siniestro.
      -- BUG 11595 - 09/11/2009 - APD - Adaptación al nuevo módulo de siniestros
      SELECT a.cgarant
        INTO v_cgarant
        FROM (SELECT pro.cgarant cgarant
                FROM siniestros SIN, prodcaumotsin pro, seguros seg
               WHERE SIN.sseguro = v_sseguro
                 AND seg.sseguro = SIN.sseguro
                 AND pro.sproduc = seg.sproduc
                 AND pro.cmotsin = SIN.cmotsin
                 AND pro.ccausin = SIN.ccausin
                 AND pro.cmotfin = 516   -- BUG12265:03/12/2009:RSC
                 AND pro.cramo = seg.cramo
                 AND SIN.nriesgo = pnriesgo
                 AND SIN.cestsin = 1
                 AND pro.cgarant = pcgarant
                 AND NVL(pac_parametros.f_parempresa_n(seg.cempres, 'MODULO_SINI'), 0) = 0
              UNION
              SELECT g.cgarant cgarant
                FROM sin_siniestro SIN, sin_movsiniestro m, sin_gar_causa_motivo g,
                     sin_causa_motivo cm, seguros seg
               WHERE SIN.sseguro = v_sseguro
                 AND seg.sseguro = SIN.sseguro
                 AND g.scaumot = cm.scaumot
                 AND g.sproduc = seg.sproduc
                 AND cm.cmotsin = SIN.cmotsin
                 AND cm.ccausin = SIN.ccausin
                 AND SIN.nsinies = m.nsinies
                 AND m.nmovsin = (SELECT MAX(nmovsin)
                                    FROM sin_movsiniestro
                                   WHERE nsinies = m.nsinies)
                 AND cm.cmotfin = 516   -- BUG12265:03/12/2009:RSC
                 AND SIN.nriesgo = pnriesgo
                 AND m.cestsin = 1
                 AND g.cgarant = pcgarant
                 AND NVL(pac_parametros.f_parempresa_n(seg.cempres, 'MODULO_SINI'), 0) = 1) a;

      RETURN 1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_validar_siniestro;

   -- BUG9496:17/03/2009:DRA
   /*************************************************************************
       FUNCTION f_valida_marcadas
       Validem que hi hagi marcada alguna garantia
       param in psseguro  : código del seguro
       param in pnriesgo  : numero de riesgo
       param in pnmovimi  : numero de movimiento
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_marcadas(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnmovimi IN NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
              := 'psseguro=' || psseguro || 'pnriesgo=' || pnriesgo || 'pnmovimi=' || pnmovimi;
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.f_valida_marcadas';
      v_numgar       NUMBER;
      v_ret          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO v_numgar
        FROM estgaranseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND nmovimi = pnmovimi
         AND cobliga = 1;

      IF v_numgar = 0 THEN
         v_ret := 103447;
      ELSE
         v_ret := 0;
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 140999;
   END f_valida_marcadas;

   -- BUG13352:DRA:24/02/2010:Inici
   /*************************************************************************
   FUNCTION ff_validacion_primaminfrac
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   return               : prima anual
   *************************************************************************/
   FUNCTION ff_validacion_primaminfrac(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
              := 'psseguro=' || psseguro || 'pnriesgo=' || pnriesgo || 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.ff_validacion_primaminfrac';
      v_numerr       NUMBER;
      v_prima        NUMBER;
   BEGIN
      v_numerr := f_validacion_primaminfrac(psproduc, psseguro, pnriesgo, v_prima);

      IF v_numerr <> 0 THEN
         RETURN -1;
      END IF;

      RETURN v_prima;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN -1;
   END ff_validacion_primaminfrac;

   /*************************************************************************
   FUNCTION ff_validacion_primamin
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   return               : prima anual
   *************************************************************************/
   FUNCTION ff_validacion_primamin(psproduc IN NUMBER, psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
              := 'psseguro=' || psseguro || 'pnriesgo=' || pnriesgo || 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.ff_validacion_primamin';
      v_numerr       NUMBER;
      v_prima        NUMBER;
   BEGIN
      v_numerr := f_validacion_primamin(psproduc, psseguro, pnriesgo, v_prima);

      IF v_numerr <> 0 THEN
         RETURN -1;
      END IF;

      RETURN v_prima;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN -1;
   END ff_validacion_primamin;

-- BUG13352:DRA:24/02/2010:Fi

   -- BUG14279:DRA:26/04/2010:Inici
   /*************************************************************************
       FUNCTION f_capmax_poliza_prestamo
       Retorna el importe maximo a asegurar
       param in psperson   : código de la persona
       param in psseguro   : código del seguro
       param in psproduc   : código del producto
       param out picapmax  : importe maximo a asegurar
       return              : 0--> OK    <> 0 --> Error
   *************************************************************************/
   FUNCTION f_capmax_poliza_prestamo(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      picapmax OUT NUMBER)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
          := 'psproduc=' || psproduc || ', psperson=' || psperson || ', psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.f_capmax_poliza_prestamo';
      v_icapmax      NUMBER;
      v_parcapmax    NUMBER;
   BEGIN
      v_parcapmax := NVL(f_parproductos_v(psproduc, 'CAPMAX'), 999999999);

      SELECT SUM(NVL(d.icapmax, v_parcapmax))
        INTO v_icapmax
        FROM riesgos r, seguros s, saldodeutorseg d
       WHERE r.sperson = psperson
         AND s.sseguro = r.sseguro
         AND s.sseguro <> psseguro
         AND d.sseguro = s.sseguro
         AND d.nmovimi = (SELECT MAX(d1.nmovimi)
                            FROM saldodeutorseg d1
                           WHERE d1.sseguro = d.sseguro)
         AND(f_vigente(r.sseguro, NULL, f_sysdate) = 0
             OR s.csituac = 4
                AND s.creteni NOT IN(3, 4))
         AND NVL(f_parproductos_v(s.sproduc, 'ES_PRODUCTO_SALDODE'), 0) = 1;

      picapmax := v_parcapmax - NVL(v_icapmax, 0);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 102556;
   END f_capmax_poliza_prestamo;

-- BUG14279:DRA:26/04/2010:Fi

   -- BUG11288:DRA:07/06/2010:Inici
   FUNCTION f_borrar_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT NULL,
      pmodo IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER IS
      --
      CURSOR c1 IS
         SELECT nriesgo
           FROM estriesgos
          WHERE sseguro = psseguro
            AND nriesgo = NVL(pnriesgo, nriesgo)
            AND ptablas = 'EST'
         UNION ALL
         SELECT nriesgo
           FROM riesgos
          WHERE sseguro = psseguro
            AND nriesgo = NVL(pnriesgo, nriesgo)
            AND NVL(ptablas, 'POL') <> 'EST';

      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(200)
         := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo || ', ptablas=' || ptablas
            || ' pmodo=' || pmodo;
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.f_borrar_riesgo';

      --
      TYPE rtablas IS RECORD(
         wtablas        VARCHAR2(100)
      );

      TYPE ttablas IS TABLE OF rtablas
         INDEX BY BINARY_INTEGER;

      vtablas        ttablas;
      vindice        NUMBER;
      num_nriesgo    NUMBER;
      vcadena        VARCHAR2(4000);
      vcadena_in     VARCHAR2(4000);
   BEGIN
      vpasexec := 100;

       -- Primero comprobamos que en el caso de pnriesgo a nulo
      -- borramos los riesgos que estan en est y no en car.
      IF pnriesgo IS NULL THEN
         vpasexec := 110;

         SELECT COUNT(*)
           INTO num_nriesgo
           FROM (SELECT nriesgo
                   FROM estriesgos
                  WHERE sseguro = psseguro
                    AND ptablas = 'EST'
                 UNION ALL
                 SELECT nriesgo
                   FROM riesgos
                  WHERE sseguro = psseguro
                    AND NVL(ptablas, 'POL') <> 'EST');

         IF num_nriesgo = 0 THEN
            RETURN 0;
         END IF;
      ELSE
         IF ptablas = 'EST' THEN
            vpasexec := 120;

            SELECT COUNT(*)
              INTO num_nriesgo
              FROM estriesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         ELSE
            vpasexec := 130;

            SELECT COUNT(*)
              INTO num_nriesgo
              FROM riesgos
             WHERE sseguro = psseguro
               AND nriesgo = pnriesgo;
         END IF;

         IF num_nriesgo = 0 THEN
            RETURN 0;
         END IF;
      END IF;

      vcadena_in := NULL;
      vpasexec := 140;

      FOR cur IN c1 LOOP
         vcadena_in := vcadena_in || cur.nriesgo || ',';
      END LOOP;

      vpasexec := 150;
      vcadena_in := SUBSTR(vcadena_in, 1, LENGTH(vcadena_in) - 1) || ')';
      --Asignamos las tablas a borrar
      vindice := 0;
      vtablas(vindice).wtablas := 'pregunseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'pregungaranseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'detgaranseg';
      -- Bug 21121 - APD - 27/02/2012 - se anade la tabla detprimas
      vtablas(vindice).wtablas := 'detprimas';
      vindice := vindice + 1;
      -- fin Bug 21121 - APD - 27/02/2012
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'garanseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'bf_bonfranseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'resulseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'claubenseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'clauparesp';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'clausuesp';
      vindice := vindice + 1;
      vpasexec := 160;

      -- BUG20234:DRA:28/11/2011:Inici
      IF pmodo IS NULL THEN
         vtablas(vindice).wtablas := 'motreten_rev';
         vindice := vindice + 1;
         vtablas(vindice).wtablas := 'motretencion';
         vindice := vindice + 1;
      END IF;

      vpasexec := 170;
      vtablas(vindice).wtablas := 'benespseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'planrentasirreg';
      vindice := vindice + 1;
      -- INI BUG 0034462 - AFM
      vtablas(vindice).wtablas := 'aseguradosmes';
      vindice := vindice + 1;
      -- FIN BUG 0034462 - AFM
      vtablas(vindice).wtablas := 'prestamoseg';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'sitriesgo';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'autdetriesgos';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'autconductores';
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'autriesgos';
      vindice := vindice + 1;

      -- BUG20234:DRA:28/11/2011:Fi
      IF ptablas = 'EST' THEN
         vpasexec := 180;
         vtablas(vindice).wtablas := 'assegurats';
      ELSE
         vpasexec := 190;
         vtablas(vindice).wtablas := 'asegurados';
      END IF;

      vpasexec := 200;
      vindice := vindice + 1;
      vtablas(vindice).wtablas := 'riesgos';
      -- la tabla riesgos tiene que ser la ultima.
      --Proceso que ejecuta los deletes correspondientes,.
      --dependiendo de los parametros.
      vindice := vtablas.FIRST;

      WHILE vindice IS NOT NULL LOOP
         vpasexec := 210;
         vcadena := 'DELETE ' || ptablas || vtablas(vindice).wtablas;
         vcadena := vcadena || ' WHERE sseguro=' || psseguro || ' AND nriesgo IN (';
         vpasexec := 220;

         IF pnriesgo IS NOT NULL THEN
            vcadena := vcadena || pnriesgo || ')';
         ELSE
            vcadena := vcadena || vcadena_in;
         END IF;

         vpasexec := 230;

         EXECUTE IMMEDIATE vcadena;

         vindice := vtablas.NEXT(vindice);
      END LOOP;

      vpasexec := 240;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG 32015:JMF:07/10/2014 Control error y mostrar sentencia que causa el problema
         -- p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM || ' ' || vcadena);
         DECLARE
            n_len          NUMBER;
            n_pos          NUMBER;
         BEGIN
            n_len := LENGTH(SQLERRM || ' ' || vcadena);
            n_pos := 1;

            WHILE n_pos < n_len LOOP
               p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                           vparam || ' lin=' || TRUNC(n_pos / 2000),
                           SUBSTR(SQLERRM || ' ' || vcadena, n_pos, 2000));
               n_pos := n_pos + 2000;
            END LOOP;
         END;

         RETURN 108017;
   END f_borrar_riesgo;

-- BUG11288:DRA:07/06/2010:Fi

   -- Bug 17221 - APD - 11/01/11 - se crea la funcion f_valida_baja_gar_col
   -- para validar si una garantia de un certificado colectivo (certificado 0)
   -- se puede dar de baja o no
   FUNCTION f_validar_baja_gar_col(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER IS
      --
      CURSOR garantias(vssegpol IN NUMBER) IS
         SELECT cgarant
           FROM garanseg
          WHERE sseguro = vssegpol
            AND nriesgo = pnriesgo
            AND ffinefe IS NULL
            AND cgarant NOT IN(SELECT g2.cgarant
                                 FROM estgaranseg g2, estseguros s2
                                WHERE g2.sseguro = s2.sseguro
                                  AND s2.ssegpol = vssegpol);

      num_err        NUMBER;
      e_cancela      EXCEPTION;
      e_cancela_pre  EXCEPTION;
      w_cgarant      garangen.cgarant%TYPE;
      vnsesion       NUMBER;
      vfefecto       DATE;
      vnpoliza       NUMBER;
      vssegpol       NUMBER;
      v_existe       NUMBER;
   BEGIN
      -- No se debe permitir dar de baja una garantia en un certificado colectivo
      -- (certificado 0) si dicha garantia esta dada de alta en algun certificado
      -- normal
      -- Para un certificado normal si se debe permitir dar de baja cualquier garantia
      SELECT npoliza, ssegpol
        INTO vnpoliza, vssegpol
        FROM estseguros
       WHERE sseguro = psseguro;

      v_existe := pac_seguros.f_get_escertifcero(vnpoliza);

      IF v_existe > 0 THEN
         w_cgarant := 0;

         FOR c IN garantias(vssegpol) LOOP
            w_cgarant := c.cgarant;

            -- 9901781: La garantia no es pot esborrar, hi ha pòlisses amb aquesta garantia.
            SELECT DECODE(COUNT(1), 0, 0, 9901781)
              INTO num_err
              FROM garanseg g, seguros s
             WHERE g.sseguro = s.sseguro
               AND s.sseguro = vssegpol
               AND g.cgarant = w_cgarant
               AND s.ncertif = 0
               AND g.ffinefe IS NULL
               AND EXISTS(SELECT 1
                            FROM garanseg g1, seguros s1
                           WHERE g1.sseguro = s1.sseguro
                             AND s.npoliza = s1.npoliza
                             AND s1.ncertif <> 0
                             AND g1.cgarant = g.cgarant
                             AND g1.ffinefe IS NULL);

            IF num_err <> 0 THEN
               EXIT;
            END IF;
         END LOOP;

         IF num_err <> 0 THEN
            RAISE e_cancela;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_cancela THEN
         IF num_err <> 0
            AND w_cgarant <> 0 THEN
            pmensa := aux_f_desgarantia(w_cgarant) || ' - ' || f_axis_literales(num_err);
         END IF;

         RETURN num_err;
      WHEN OTHERS THEN
         RETURN 140999;   -- Error no controlado
   END f_validar_baja_gar_col;

-- Fin Bug 17221
   /*************************************************************************
       PROCEDURE p_select_tarifar_detalle
       Marca con CUNICA = 3 la línea de detalle de garantía que se debe
       tarificar, y con CUNICA = 2 las que no se deben tarificar.
       Las líneas de detalle con CUNICA = 1 se dejan tal como están.
       param in psseguro : código de seguro
       param in pnriesgo : número de riesgo
       param in pnmovimi : número de movimiento
       param in pcgarant : código de garantía
   *************************************************************************/
   -- Bug 17341 - 24/01/2011 - JMP - Se crea la función
   PROCEDURE p_select_tarifar_detalle(
      psseguro IN NUMBER,
      psolicit IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER) IS
      CURSOR c_dif_preggar(p_cpregun NUMBER) IS
         SELECT cpregun, crespue
           FROM estpregungaranseg
          WHERE sseguro = psolicit
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND cpregun = NVL(p_cpregun, cpregun)
            AND nmovimi = pnmovimi
         MINUS
         SELECT cpregun, crespue
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND cpregun = NVL(p_cpregun, cpregun)
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregungaranseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo);

      CURSOR c_dif_pregpol IS
         SELECT cpregun, crespue
           FROM estpregunpolseg
          WHERE sseguro = psolicit
            AND nmovimi = pnmovimi
            AND cpregun = 133
         MINUS
         SELECT cpregun, crespue
           FROM pregunpolseg
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunpolseg
                            WHERE sseguro = psseguro)
            AND cpregun = 133;

      vr_dif         c_dif_preggar%ROWTYPE;
      --vr_dif_pp      c_dif_pregpol%ROWTYPE;
      v_ctipcap      garanpro.ctipcap%TYPE;
      v_iprianu      estdetgaranseg.iprianu%TYPE;
      v_ctarifa      estdetgaranseg.ctarifa%TYPE;
      v_pinttec      estdetgaranseg.pinttec%TYPE;
      v_tarifar      NUMBER(1);
   BEGIN
      -- Si ha habido cambios en la fecha de vencimiento a nivel de garantía
      -- actualizamos la fecha de los detalles de garantía con la introducida por pantalla
      OPEN c_dif_preggar(1043);

      FETCH c_dif_preggar
       INTO vr_dif;

      IF c_dif_preggar%FOUND THEN
         UPDATE estdetgaranseg
            SET fvencim = TO_DATE(vr_dif.crespue, 'YYYYMMDD')
          WHERE sseguro = psolicit
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = pnmovimi;
      END IF;

      CLOSE c_dif_preggar;

      SELECT ctipcap
        INTO v_ctipcap
        FROM garanpro g, seguros s
       WHERE s.sseguro = psseguro
         AND g.sproduc = s.sproduc
         AND g.cactivi = s.cactivi
         AND g.cgarant = pcgarant;

      IF v_ctipcap = 4 THEN
         -- Las garantías con este tipo de capital (Forfait) no se deben tarifar
         v_tarifar := 0;
      ELSE
         -- Si ha habido cambio de tarifa (pregunta a nivel de póliza 133) actualizamos
         -- los campos CTARIFA y PINTTEC de ESTDETGARANSEG
         OPEN c_dif_pregpol;

         FETCH c_dif_pregpol
          INTO vr_dif;

         IF c_dif_pregpol%FOUND THEN
            v_tarifar := 1;
            v_ctarifa := vr_dif.crespue;
            v_pinttec := f_gettramo1(f_sysdate, f_gettramo1(f_sysdate, 1363, v_ctarifa),
                                     pcgarant);
         END IF;

         CLOSE c_dif_pregpol;

         IF v_tarifar = 0 THEN
            -- Miramos si ha habido cambios en alguna pregunta del riesgo
            SELECT DECODE(COUNT(*), 0, 0, 1)
              INTO v_tarifar
              FROM (SELECT cpregun, crespue
                      FROM estpregunseg
                     WHERE sseguro = psolicit
                       AND nriesgo = pnriesgo
                       AND nmovimi = pnmovimi
                    MINUS
                    SELECT cpregun, crespue
                      FROM pregunseg
                     WHERE sseguro = psseguro
                       AND nriesgo = pnriesgo
                       AND nmovimi = (SELECT MAX(nmovimi)
                                        FROM pregunseg
                                       WHERE sseguro = psseguro
                                         AND nriesgo = pnriesgo));

            IF v_tarifar = 0 THEN
               -- Miramos si ha habido cambios en alguna pregunta de la garantía
               OPEN c_dif_preggar(NULL);

               FETCH c_dif_preggar
                INTO vr_dif;

               IF c_dif_preggar%FOUND THEN
                  v_tarifar := 1;
               ELSE
                  v_tarifar := 0;
               END IF;

               CLOSE c_dif_preggar;
            END IF;
         END IF;
      END IF;

      IF v_tarifar = 0 THEN
         UPDATE estdetgaranseg e
            SET cunica = 2
          WHERE sseguro = psolicit
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = pcgarant
            AND cunica <> 1;
      ELSE
         -- Si el capital es fijo, variable o dependiente, pondremos la prima a 0 para
         -- que se calculen correctamente las preguntas automáticas y la suma de garantías
         IF v_ctipcap IN(1, 2, 6) THEN
            v_iprianu := 0;
         END IF;

         UPDATE estdetgaranseg e
            SET cunica = 3,
                iprianu = NVL(v_iprianu, iprianu),
                ctarifa = NVL(v_ctarifa, ctarifa),
                pinttec = NVL(v_pinttec, pinttec)
          WHERE sseguro = psolicit
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = pcgarant
            AND ndetgar = (SELECT MAX(ndetgar)
                             FROM estdetgaranseg
                            WHERE sseguro = e.sseguro
                              AND nriesgo = e.nriesgo
                              AND nmovimi = e.nmovimi
                              AND cgarant = e.cgarant
                              AND cunica <> 1);

         UPDATE estdetgaranseg e
            SET cunica = 2
          WHERE sseguro = psolicit
            AND nriesgo = pnriesgo
            AND nmovimi = pnmovimi
            AND cgarant = pcgarant
            AND cunica <> 1
            AND ndetgar <> (SELECT MAX(ndetgar)
                              FROM estdetgaranseg
                             WHERE sseguro = e.sseguro
                               AND nriesgo = e.nriesgo
                               AND nmovimi = e.nmovimi
                               AND cgarant = e.cgarant
                               AND cunica <> 1);
      END IF;
   END p_select_tarifar_detalle;

   /*************************************************************************
       FUNCTION f_marcar_dep_multiples
       Función para marcar las garantías multiples dependientes
       param in psproduc : código de producto
       param in pcactivi : código de actividad
       param in pcgarant : código de garantía
       param in psseguro : código de seguro
       param in pnriesgo : número de riesgo
       param in pnmovimi : número de movimiento
       param in out pmensa : texto de error
       param in out pnmovima : número de movimiento alta
   *************************************************************************/
   --Bug.: 18350 - ICV - 29/04/2011
   FUNCTION f_marcar_dep_multiples(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      v_dummy        NUMBER;
      v_ctipgar      garanpro.ctipgar%TYPE;
      v_contratar    NUMBER := 0;
   BEGIN
      -- per obtenir si hi ha cap garantia que depengui de les garanties afectades.
      SELECT COUNT(1)
        INTO v_dummy
        FROM (SELECT cgarant
                FROM dep_garantias
               WHERE cgarpar = pcgarant
                 AND sproduc = psproduc
                 AND cactivi = pcactivi
              UNION ALL
              SELECT cgarant
                FROM dep_garantias
               WHERE cgarpar = pcgarant
                 AND sproduc = psproduc
                 AND cactivi = 0);

      IF v_dummy = 0 THEN
         RETURN 0;
      END IF;

      FOR rc IN (SELECT cgarant
                   FROM dep_garantias
                  WHERE cgarpar = pcgarant
                    AND sproduc = psproduc
                    AND cactivi = pcactivi
                 UNION ALL
                 SELECT cgarant
                   FROM dep_garantias
                  WHERE cgarpar = pcgarant
                    AND sproduc = psproduc
                    AND cactivi = 0
                    AND NOT EXISTS(SELECT 1
                                     FROM dep_garantias
                                    WHERE cgarpar = pcgarant
                                      AND sproduc = psproduc
                                      AND cactivi = pcactivi)) LOOP
         --marquem totes aquelles que cumpleixin les condicions i sigui dep. obli. multiple
         -- s'obté el tipus de garantia
         BEGIN
            SELECT ctipgar
              INTO v_ctipgar
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = rc.cgarant
               AND cactivi = pcactivi;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT ctipgar
                 INTO v_ctipgar
                 FROM garanpro
                WHERE sproduc = psproduc
                  AND cgarant = rc.cgarant
                  AND cactivi = 0;
         END;

         IF paccion = 'SEL' THEN
            IF v_ctipgar = 6 THEN   --marquem totes aquelles que cumpleixin les condicions i sigui dep. obli. multiple
               v_contratar := pk_nueva_produccion.f_cumpleix_dep_multiple(psproduc, pcactivi,
                                                                          rc.cgarant,
                                                                          psseguro, pnriesgo,
                                                                          pnmovimi, pmensa,
                                                                          pnmovima);

               IF NVL(v_contratar, 0) = 1 THEN
                  UPDATE estgaranseg
                     SET cobliga = 1,
                         icapital = 0
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND cgarant = rc.cgarant;

                  -- Bug 21786 - APD - 28/03/2012 - se llama a f_validacion_cobliga si ha habido
                  -- un cambio en la garantia
                  num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, rc.cgarant,
                                                  paccion, psproduc, pcactivi, pmensa,
                                                  pnmovima);
               -- fin Bug 21786 - APD - 28/03/2012
               -- Bug 22964 - APD - 14/09/2012 - si no se cumple la condicion, se
               -- desmarca la garantia automaticamente
               ELSE
                  UPDATE estgaranseg
                     SET cobliga = 0,
                         icapital = NULL
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND cgarant = rc.cgarant;

                  -- Bug 21786 - APD - 28/03/2012 - se llama a f_validacion_cobliga si ha habido
                  -- un cambio en la garantia
                  num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, rc.cgarant,
                                                  'DESEL', psproduc, pcactivi, pmensa,
                                                  pnmovima);
               -- fin Bug 21786 - APD - 28/03/2012
               -- fin Bug 22964 - APD - 14/09/2012
               END IF;
            END IF;
         ELSE
            v_contratar := pk_nueva_produccion.f_cumpleix_dep_multiple(psproduc, pcactivi,
                                                                       rc.cgarant, psseguro,
                                                                       pnriesgo, pnmovimi,
                                                                       pmensa, pnmovima);

            IF v_ctipgar IN(5, 6) THEN   --desmarquem totes aquelles que incumpleixin les condicions i sigui dep. obli. multiple o opcionals
               --v_contratar := pk_nueva_produccion.f_cumpleix_dep_multiple();
               -- Bug 21786 - APD - 21/05/2012 - se anade la condicion OR v_contratar <> 1
               -- para el caso que la funcion f_cumpleix_dep_multiple devuelva un num_err
               -- por la validacion en dep_garantias.tvalgar
               IF NVL(v_contratar, 0) = 0
                  OR NVL(v_contratar, 0) <> 1 THEN
                  -- fin Bug 21786 - APD - 21/05/2012
                  UPDATE estgaranseg
                     SET cobliga = 0,
                         icapital = NULL
                   WHERE sseguro = psseguro
                     AND nriesgo = pnriesgo
                     AND cgarant = rc.cgarant;

                  -- Bug 21786 - APD - 28/03/2012 - se llama a f_validacion_cobliga si ha habido
                  -- un cambio en la garantia
                  num_err := f_validacion_cobliga(psseguro, pnriesgo, pnmovimi, rc.cgarant,
                                                  paccion, psproduc, pcactivi, pmensa,
                                                  pnmovima);
               -- fin Bug 21786 - APD - 28/03/2012
               END IF;
            END IF;
         END IF;

         --Ahora se comprueba recursivamente si la nueva tiene dependencia
         -- Bug 21786 - APD - 38/03/2011 - la nueva garanita puede ser dependiente
         -- multiple o no, por eso tambien se tiene que llamar a la funcion f_marcar_dep_obliga
         num_err := f_marcar_dep_obliga(paccion, psproduc, pcactivi, rc.cgarant, psseguro,
                                        pnriesgo, pnmovimi, pmensa, pnmovima);
         -- fin Bug 21786 - APD - 38/03/2011
         num_err := pk_nueva_produccion.f_marcar_dep_multiples(paccion, psproduc, pcactivi,
                                                               rc.cgarant, psseguro, pnriesgo,
                                                               pnmovimi, pmensa, pnmovima);
      END LOOP;

      RETURN num_err;
   END f_marcar_dep_multiples;

    /*************************************************************************
       FUNCTION f_cumpleix_dep_multiple
       Función para marcar las garantías multiples dependientes
       param in psproduc : código de producto
       param in pcactivi : código de actividad
       param in pcgarant : código de garantía
       param in psseguro : código de seguro
       param in pnriesgo : número de riesgo
       param in pnmovimi : número de movimiento
       param in out pmensa : texto de error
       param in out pnmovima : número de movimiento alta
   *************************************************************************/
   --Bug.: 18350 - ICV - 01/05/2011
   FUNCTION f_cumpleix_dep_multiple(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      v_dummy        NUMBER;
      v_ctipgar      garanpro.ctipgar%TYPE;
      v_contratar    NUMBER := 0;

      CURSOR c_reglas IS
         SELECT   sproduc, cactivi, cgarant, norden, nsubord, cgarpar
             FROM dep_garantias dep
            WHERE dep.cgarant = pcgarant
              AND dep.sproduc = psproduc
              AND dep.cactivi = pcactivi
         UNION ALL
         SELECT   sproduc, cactivi, cgarant, norden, nsubord, cgarpar
             FROM dep_garantias dep
            WHERE dep.cgarant = pcgarant
              AND dep.sproduc = psproduc
              AND dep.cactivi = 0
              AND NOT EXISTS(SELECT 1
                               FROM dep_garantias dep1
                              WHERE dep1.cgarant = pcgarant
                                AND dep1.sproduc = psproduc
                                AND dep1.cactivi = pcactivi)
         ORDER BY nsubord, norden;

      v_query        VARCHAR2(4000);
      v_auxsubord    NUMBER := 1;
      v_resultado    NUMBER := 0;
      -- Bug 21786 - APD - 10/04/2012
      vtrotgar       garangen.trotgar%TYPE := NULL;
      vtrotgar_final VARCHAR2(5000) := NULL;
      -- fin Bug 21786 - APD - 10/04/2012
      v_cumple       NUMBER := 0;   -- Bug 21786 - APD - 18/05/2012
   BEGIN
      FOR rc IN c_reglas LOOP
         IF rc.norden = 1
            AND rc.nsubord = 1 THEN
            v_query := ' select count(''1'') from dual where (';
         END IF;

         IF v_auxsubord = rc.nsubord THEN   --Mientras sea el mismo vamos haciendo AND
            IF rc.norden = 1 THEN
               v_query := v_query || ' ( ';
               v_query := v_query || ' (SELECT count(''1'') from estgaranseg where sseguro = '
                          || psseguro || ' and ';
--               v_query := v_query || ' cobliga = 1 and cgarant = ' || rc.cgarpar || ') ';
               v_query := v_query || ' cobliga = 1 and cgarant = ' || rc.cgarpar;   -- || ') ';  -- Bug 21664/0109957 - FAL - 23/03/2012
               v_query := v_query || ' and nriesgo = NVL(' || pnriesgo || ', nriesgo)' || ') ';
            ELSE
               v_query := v_query
                          || ' and (SELECT count(''1'') from estgaranseg where sseguro = '
                          || psseguro || ' and ';
--               v_query := v_query || ' cobliga = 1 and cgarant = ' || rc.cgarpar || ') ';
               v_query := v_query || ' cobliga = 1 and cgarant = ' || rc.cgarpar;   -- || ') ';   -- Bug 21664/0109957 - FAL - 23/03/2012
               v_query := v_query || ' and nriesgo = NVL(' || pnriesgo || ', nriesgo)' || ') ';
            END IF;
         ELSE   --Hacemos un OR
            v_query := v_query || ') or (';
            v_query := v_query || ' (SELECT count(''1'') from estgaranseg where sseguro = '
                       || psseguro || ' and ';
--            v_query := v_query || ' cobliga = 1 and cgarant = ' || rc.cgarpar || ') ';
            v_query := v_query || ' cobliga = 1 and cgarant = ' || rc.cgarpar;   -- || ') ';      -- Bug 21664/0109957 - FAL - 23/03/2012
            v_query := v_query || ' and nriesgo = NVL(' || pnriesgo || ', nriesgo)' || ') ';
            v_auxsubord := rc.nsubord;
         END IF;

         v_query := v_query || ' = 1 ';

         -- Bug 21786 - APD - 10/04/2012 - se busca la descripcion de las garantias
         -- de las cual depende
         BEGIN
            SELECT trotgar
              INTO vtrotgar
              FROM garangen
             WHERE cidioma = f_usu_idioma
               AND cgarant = rc.cgarpar;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vtrotgar := NULL;
         END;

         IF vtrotgar_final IS NULL THEN
            vtrotgar_final := vtrotgar;
         ELSE
            vtrotgar_final := vtrotgar_final || '; ' || vtrotgar;
         END IF;
      -- fin Bug 21786 - APD - 10/04/2012
      END LOOP;

      v_query := v_query || ') )';

      EXECUTE IMMEDIATE v_query
                   INTO v_resultado;

      IF v_resultado > 0 THEN
         v_cumple := 1;   --RETURN 1;   --Cumple -- Bug 21786 - APD - 18/05/2012
      ELSE
         -- Bug 21786 - APD - 10/04/2012 - si no cumple, se debe mostrar en el mensaje de
         -- salida las garantias de las cual depende
         pmensa := vtrotgar_final;
         -- fin Bug 21786 - APD - 10/04/2012
         v_cumple := 0;   -- RETURN 0;   --No Cumple -- Bug 21786 - APD - 18/05/2012
      END IF;

      -- Bug 21786 - APD - 18/05/2012 - si se cumplen todas las dependencias de garantias,
      -- además hay que mirar si se cumplen otras validaciones que se puedan dar
      IF v_cumple = 1 THEN
         num_err := pk_nueva_produccion.f_valida_dep_garantias(pcgarant, psseguro, pnriesgo,
                                                               pnmovimi, psproduc, pcactivi,
                                                               pmensa);

         IF num_err <> 0 THEN
            v_cumple := num_err;   --No Cumple
         END IF;
      END IF;

      -- fin Bug 21786 - APD - 18/05/2012
      RETURN v_cumple;
   END f_cumpleix_dep_multiple;

   -- Ini bug 18345 - SRA - 02/05/2011
   /*************************************************************************
      FUNCTION f_valida_garanproval
      Función que recorrerá GARANPRO_VALIDACION y recuperará las funciones que de validación que se han definido
      para las garantías seleccionadas.
      pcgarant in number: código de la garantía
      pcobliga in number: indicador de si la garantía está marcada
      psseguro in number: identificador del seguro
      pnriesgo in number: número del riesgo
      pnmovimi in number: número de movimiento
      psproduc in number: código de producto
      pcactivi in number: código de la actividad
      pmensa in out number: parámetro de entrada/salida
      return number: retorno de la función f_valida_garanproval
   *************************************************************************/
   FUNCTION f_valida_garanproval(
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pcprepost IN VARCHAR2 DEFAULT NULL)   -- Bug 19412/95066 - RSC - 19/10/2011
      RETURN NUMBER IS
      vnresult       NUMBER;
      vnvalidacio    NUMBER;
      vtparam        tab_error.tdescrip%TYPE;
      vobject        tab_error.tobjeto%TYPE := 'pk_nueva_produccion.f_valida_garanproval';
      vpasexec       NUMBER := 0;
      vnordval       NUMBER;

      CURSOR c_validaciones IS
         SELECT   g.sproduc, g.cgarant, g.cactivi, g.nordval, g.tvalgar
             FROM garanpro_validacion g
            WHERE g.sproduc = psproduc
              AND g.cgarant = pcgarant
              AND g.cactivi = pcactivi
              AND(g.cprepost = pcprepost
                  OR g.cprepost IS NULL)   -- Bug 19412/95066 - RSC - 19/10/2011
         UNION ALL
         SELECT   g.sproduc, g.cgarant, g.cactivi, g.nordval, g.tvalgar
             FROM garanpro_validacion g
            WHERE g.sproduc = psproduc
              AND g.cgarant = pcgarant
              AND g.cactivi = 0
              AND(g.cprepost = pcprepost
                  OR g.cprepost IS NULL)
              AND NOT EXISTS(SELECT 1
                               FROM garanpro_validacion g1
                              WHERE g1.sproduc = psproduc
                                AND g1.cgarant = pcgarant
                                AND g1.cactivi = pcactivi
                                AND(g1.cprepost = pcprepost
                                    OR g1.cprepost IS NULL))
         ORDER BY 4;
   BEGIN
      vtparam := 'pcgarant: ' || pcgarant || ' - ' || 'psseguro: ' || psseguro || ' - '
                 || 'pnriesgo: ' || pnriesgo || ' - ' || 'pnmovimi: ' || pnmovimi || ' - '
                 || 'psproduc: ' || psproduc || ' - ' || 'pcactivi: ' || pcactivi || ' - '
                 || 'pmensa: ' || pmensa;
      vpasexec := 1;
      -- BUG 29582/0164461 - APD - 28/01/2014
      pmensa := ff_desgarantia(pcgarant, f_usu_idioma);
      --pmensa := NULL;

      -- fin BUG 29582/0164461 - APD - 28/01/2014
      FOR i IN c_validaciones LOOP
         vpasexec := 2;
         vnordval := i.nordval;
         vnresult := pac_albsgt.f_tvalgar(i.tvalgar, 'EST', psseguro, pnriesgo, pnmovimi,
                                          pcgarant, pcactivi, vnvalidacio);
         vpasexec := 3;

         -- Si ha ocurrido un error retornamos
         IF NVL(vnresult, -1) != 0 THEN
            RETURN vnresult;
         END IF;

         vpasexec := 4;

         -- Si la garantía no ha superado la validación retornamos
         IF NVL(vnvalidacio, -1) != 0 THEN
            RETURN vnvalidacio;
         END IF;
      END LOOP;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         vtparam := vtparam || ' - vnordval: ' || vnordval;
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9901995;
   END f_valida_garanproval;

-- Fi bug 18345 - SRA - 02/05/2011
   -- Ini bug 19303 - JMC - 21/11/2011
   /*************************************************************************
      FUNCTION f_crearpropuesta_sp
      Función que generara una póliza del producto SALDAR o PRORROGAR, tomando
      los datos de una póliza origen
      psseguro in number: código del seguro origen
      piprima_np in number:
      picapfall_np in number: capital fallecimiento de la nueva póliza
      pfvencim_np in date: fecha vencimiento de la nueva póliza
      pfecha in date: fecha efecto nueva póliza
      pmode in number: Modo
      psolicit out number: Número solicitud.
      purl out varchar2:
      pmensa in out varchar2: mensajes de error.
      return number: retorno de la función f_crearpropuesta_sp
   *************************************************************************/
   FUNCTION f_crearpropuesta_sp(
      psseguro IN NUMBER,
      piprima_np IN NUMBER,
      picapfall_np IN NUMBER,
      pfvencim_np IN DATE,
      pmode IN VARCHAR2,
      pfecha IN DATE,
      pssolicit OUT NUMBER,
      purl OUT VARCHAR2,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pmodo=' || pmode || ', psseguro=' || psseguro || ', piprima_np=' || piprima_np
            || ', picapfall_np=' || picapfall_np || ', pfvencim_np=' || pfvencim_np
            || ', pfecha=' || pfecha || ', pssolicit=' || pssolicit || ', purl=' || purl
            || ', pmensa=' || pmensa;
      vobject        VARCHAR2(200) := 'pk_nueva_produccion.f_crearpropuesta_sp';
      numerr         NUMBER;
      vseg           seguros%ROWTYPE;
      vprod          productos%ROWTYPE;
      vsproduc_dest  productos.sproduc%TYPE;   -- Código producto destino
      vpar           parproductos.cparpro%TYPE;
      vsseguro       seguros.sseguro%TYPE;
      vssegpol       estseguros.ssegpol%TYPE;
      vccobban       estseguros.ccobban%TYPE;
      vfvencim       estseguros.fvencim%TYPE;
      vnduraci       estseguros.nduraci%TYPE;
      vnrenova       estseguros.nrenova%TYPE;
      vndurcob       estseguros.ndurcob%TYPE;
      vnpoliza       estseguros.npoliza%TYPE;
      vncertif       estseguros.ncertif%TYPE;
      vnsolici       estseguros.nsolici%TYPE;
      vnumaddpoliza  NUMBER;
      vtipo          NUMBER;   --LECG 15/11/2012 BUG: 24714 - Inserta el vtipo

      TYPE rnriesgo IS RECORD(
         nrieold        NUMBER,
         nrienew        NUMBER
      );

      TYPE tnriesgos IS TABLE OF rnriesgo
         INDEX BY BINARY_INTEGER;

      vnriesgos      tnriesgos;
      vind           NUMBER;
      vnmovimi       movseguro.nmovimi%TYPE;
      vnriesgo       riesgos.nriesgo%TYPE;
      vctipgar       garanpro.ctipgar%TYPE;
      vsperson       per_personas.sperson%TYPE;
      vsperson_new   per_personas.sperson%TYPE;
      vpinttec       estintertecseg.pinttec%TYPE;
      vpinttec2      estintertecseg.pinttec%TYPE;
   BEGIN
      --Leemos el seguro que se salda o reemplaza
      SELECT *
        INTO vseg
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      IF pmode = 'SALDAR' THEN
         vpar := 'PRODUCTO_SALDAR';
         vtipo := 3;   --LECG 15/11/2012 BUG: 24714 - Inserta el vtipo
      ELSE
         vpar := 'PRODUCTO_PRORROGAR';
         vtipo := 2;   --LECG 15/11/2012 BUG: 24714 - Inserta el vtipo
      END IF;

      vsproduc_dest := pac_parametros.f_parproducto_n(vseg.sproduc, vpar);
      vpasexec := 3;

      -- Obtenemos las caracteristicas del producto destino
      SELECT *
        INTO vprod
        FROM productos
       WHERE sproduc = vsproduc_dest;

      vpasexec := 4;

      SELECT sestudi.NEXTVAL
        INTO vsseguro
        FROM DUAL;

      pssolicit := vsseguro;
      vpasexec := 5;

      SELECT sseguro.NEXTVAL
        INTO vssegpol
        FROM DUAL;

      vpasexec := 6;

      --Obtenemos caracteristicas de la póliza origen.
      SELECT *
        INTO vseg
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 7;
      vnumaddpoliza := pac_parametros.f_parempresa_n(vseg.cempres, 'NUMADDPOLIZA');
      vnpoliza := vsseguro + NVL(vnumaddpoliza, 0);
      vpasexec := 8;

      IF vprod.csubpro = 3
         OR NVL(f_parproductos_v(vprod.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
         IF NVL(f_parproductos_v(vprod.sproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 THEN
            SELECT ssolicit_certif.NEXTVAL
              INTO vncertif
              FROM DUAL;
         END IF;
      ELSE
         -- Si el npoliza se asigan en la emisión, se graba el número de solicitud
         IF NVL(f_parproductos_v(vprod.sproduc, 'NPOLIZA_EN_EMISION'), 0) = 1 THEN
            vnsolici := pac_propio.f_numero_solici(vseg.cempres, vprod.cramo);
         END IF;

         vncertif := 0;
      END IF;

      vpasexec := 9;

      IF NVL(vseg.cbancar, ' ') <> ' ' THEN
         vccobban := f_buscacobban(vprod.cramo, vprod.cmodali, vprod.ctipseg, vprod.ccolect,
                                   vseg.cagente, vseg.cbancar, NVL(vseg.ctipban, 1), numerr);

         IF numerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'f_crea_pol_sp', vpasexec,
                        'Error (' || numerr || ') al obtener cobrador bancario ',
                        'Params: cramo=' || vprod.cramo || ', cmodali=' || vprod.cmodali
                        || ', ctipseg=' || vprod.ctipseg || ', ccolect=' || vprod.ccolect
                        || ', cagente=' || vseg.cagente || ', cbancar=' || vseg.cbancar
                        || ', ctipban=' || vseg.ctipban);
            RETURN numerr;
         END IF;
      END IF;

      vpasexec := 10;
      vfvencim := pfvencim_np;

      -- Bug 24715 - ETM - 24/05/2013 --(POSPG600)-Revisar anulaciones y Rehabilitaciones
      IF pmode = 'SALDAR'
         AND vfvencim IS NULL
         AND NVL(pac_parametros.f_parempresa_n(vseg.cempres, 'F_VECIM_SALDADO'), 0) = 1 THEN
         vfvencim := vseg.fvencim;
      END IF;

      vpasexec := 11;
      -- FIN Bug 24715 - ETM - 24/05/2013 --(POSPG600)-Revisar anulaciones y Rehabilitaciones
      numerr := pac_calc_comu.f_calcula_fvencim_nduraci(vprod.sproduc, pfecha, pfecha,
                                                        vprod.cduraci, vnduraci, vfvencim,
                                                        vseg.nedamar);   -- Bug 25584 MMS add NEDAMAR

      IF numerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'f_crea_pol_sp', vpasexec,
                     'Error (' || numerr || ') al calcular vencimiento y duración',
                     'Params: produc=' || vprod.sproduc || ', pfecha=' || pfecha
                     || ', cduraci=' || vprod.cduraci);
         RETURN numerr;
      END IF;

      vpasexec := 12;
      numerr := pac_calc_comu.f_calcula_nrenova(vprod.sproduc, pfecha, vnrenova);

      IF numerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'f_crea_pol_sp', vpasexec,
                     'Error (' || numerr || ') al calcular nrenova ',
                     'Params: sproduc=' || vprod.sproduc || ', pfecha=' || pfecha);
         RETURN numerr;
      END IF;

      vpasexec := 13;
      numerr := pac_calc_comu.f_calcula_ndurcob(vprod.sproduc, vnduraci, vndurcob);

      IF numerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, 'f_crea_pol_sp', vpasexec,
                     'Error (' || numerr || ') al calcular ndurcob ',
                     'Params: sproduc=' || vprod.sproduc || ', nduraci=' || vnduraci);
         RETURN numerr;
      END IF;

      vpasexec := 14;

      INSERT INTO estseguros
                  (sseguro, cmodali, ccolect, ctipseg, casegur,
                   cagente, cramo, npoliza, ncertif, nsuplem, fefecto, creafac,
                   ctarman, cobjase, ctipreb, cactivi, ccobban, ctipcoa,
                   ctiprea, crecman, creccob, ctipcom, fvencim, femisio, fanulac, fcancel,
                   csituac, cbancar, ctipcol, fcarant, fcarpro, fcaranu, cduraci, nduraci,
                   nanuali, iprianu, cidioma, nfracci, cforpag, pdtoord, nrenova, crecfra,
                   tasegur, creteni, ndurcob, sciacoa, pparcoa, npolcoa, nsupcoa, tnatrie,
                   pdtocom, prevali, irevali, ncuacoa, nedamed,
                   crevali, cempres, cagrpro, ssegpol, ctipest, ccompani,
                   nparben, nbns, ctramo, cpolcia, cindext,
                   pdispri, idispri, cimpase, sproduc, intpres,
                   nmescob, cnotibaja, ccartera, cagencorr, nsolici,
                   fimpsol, sprodtar, ctipcob, ctipban, polissa_ini, csubage,
                   cpromotor)
           VALUES (vsseguro, vprod.cmodali, vprod.ccolect, vprod.ctipseg, vseg.casegur,
                   vseg.cagente, vprod.cramo, vnpoliza, vncertif, 0, pfecha, vseg.creafac,
                   vprod.ctarman, vprod.cobjase, vprod.ctipreb, 
				   --INI-CES:22/05/2019=> Ajuste error en cambio de actividad para suplementos
				   VSEG.CACTIVI, 
				   --END-CES:22/05/2019=> Ajuste error en cambio de actividad para suplementos
				   vccobban, vseg.ctipcoa,
                   vseg.ctiprea, 0, vprod.creccob, vseg.ctipcom, vfvencim, NULL, NULL, NULL,
                   4, vseg.cbancar, 1, NULL, NULL, NULL, vprod.cduraci, vnduraci,
                   1, 0, vseg.cidioma, 0, vprod.cpagdef, NULL, vnrenova, vprod.crecfra,
                   vseg.tasegur, 0, vndurcob, NULL, NULL, NULL, NULL, NULL,
                   vseg.pdtocom, vprod.prevali, vprod.irevali, vseg.ncuacoa, vseg.nedamed,
                   vprod.crevali, vseg.cempres, vprod.cagrpro, vssegpol, NULL, vseg.ccompani,
                   vseg.nparben, vseg.nbns, vseg.ctramo, vseg.cpolcia, vseg.cindext,
                   vseg.pdispri, vseg.idispri, vseg.cimpase, vprod.sproduc, vseg.intpres,
                   vseg.nmescob, vseg.cnotibaja, vseg.ccartera, vseg.cagencorr, vnsolici,
                   NULL, vseg.sprodtar, vseg.ctipcob, vseg.ctipban, NULL, vseg.csubage,
                   vseg.cpromotor);

      INSERT INTO estdetmovseguro
                  (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalord, cpregun)
           VALUES (vsseguro, 1, 100, 0, 0, 'Alta de pólizas', 0);

      vpasexec := 15;

      --Copiamos Tomadores.
      FOR x IN (SELECT   *
                    FROM tomadores
                   WHERE sseguro = psseguro
                ORDER BY sperson) LOOP
         pac_persona.traspaso_tablas_per(x.sperson, vsperson_new, vsseguro, vseg.cagente);

         INSERT INTO esttomadores
                     (sperson, sseguro, cdomici, nordtom, cagrupa) --IAXIS-2085 03/04/2019 AP
              VALUES (vsperson_new, vsseguro, x.cdomici, x.nordtom, x.cagrupa); --IAXIS-2085 03/04/2019 AP
      END LOOP;

      vpasexec := 16;

      --BFP 09/01/2012 bug: 19303
      INSERT INTO estreemplazos
                  (sseguro, sreempl, fmovdia, cusuario, cagente, ctipo)
           VALUES (vsseguro, psseguro, f_sysdate(), f_user(), vseg.cagente, vtipo);

      vpasexec := 17;
      --Copiamos riesgos
      vind := 1;

      FOR x IN (SELECT   *
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND fanulac IS NULL
                ORDER BY nriesgo) LOOP
         pac_persona.traspaso_tablas_per(x.sperson, vsperson_new, vsseguro, vseg.cagente);

         INSERT INTO estriesgos
                     (nriesgo, sseguro, nmovima, fefecto, sperson, cclarie, nmovimb, fanulac,
                      tnatrie, cdomici, nasegur, starjet, nedacol, csexcol, sbonush,
                      czbonus, ctipdiraut, spermin, cactivi, cmodalidad)
              VALUES (vind, vsseguro, 1, pfecha, vsperson_new, x.cclarie, NULL, NULL,
                      x.tnatrie, x.cdomici, x.nasegur, NULL, x.nedacol, x.csexcol, x.sbonush,
                      x.czbonus, x.ctipdiraut, x.spermin, 0, x.cmodalidad);

         vnriesgos(vind).nrieold := x.nriesgo;
         vnriesgos(vind).nrienew := vind;
         vpasexec := 18;

         --Copiamos asegurados
         INSERT INTO estassegurats
                     (sseguro, sperson, norden, cdomici, ffecini, ffecfin, ffecmue, nriesgo,
                      fecretroact, cparen)   --bfp bug 22481
            SELECT vsseguro, vsperson_new, norden, cdomici, pfecha, NULL, ffecmue, vind,
                   fecretroact, cparen   -- bfp bug 22481
              FROM asegurados
             WHERE sseguro = psseguro
               AND nriesgo = x.nriesgo;

         vind := vind + 1;
      END LOOP;

      vpasexec := 19;

      --Obtenemos las preguntas de pólizas comunes entre el producto origen,
      --producto destino y el último movimiento de la póliza origen.
      FOR x IN (SELECT cpregun
                  FROM pregunpro
                 WHERE sproduc = vseg.sproduc
                   AND cnivel IN('P', 'C')   -- BUG20498:DRA:10/01/2012
                   AND cpregun NOT IN(4044, 4046)
                UNION
                SELECT cpregun
                  FROM pregunpro
                 WHERE sproduc = vsproduc_dest
                   AND cnivel IN('P', 'C')   -- BUG20498:DRA:10/01/2012
                   AND cpregun NOT IN(4044, 4046)
                UNION
                SELECT cpregun
                  FROM pregunpolseg p1
                 WHERE sseguro = psseguro
                   AND nmovimi = (SELECT MAX(nmovimi)
                                    FROM pregunpolseg p2
                                   WHERE sseguro = psseguro
                                     AND cpregun = p1.cpregun
                                     AND cpregun NOT IN(4044, 4046))
                   AND cpregun NOT IN(4044, 4046)) LOOP
         -- Bug 21780 - RSC - 23/03/2012 - Afegim DECODE(cpregun ...
         INSERT INTO estpregunpolseg
                     (sseguro, cpregun, crespue, nmovimi, trespue)
            SELECT vsseguro, DECODE(cpregun, 4777, 4775, cpregun), crespue, 1, trespue
              FROM pregunpolseg p1
             WHERE sseguro = psseguro
               AND cpregun = x.cpregun
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM pregunpolseg p2
                               WHERE sseguro = psseguro
                                 AND cpregun = p1.cpregun);
      END LOOP;

      vpasexec := 20;

      BEGIN
         INSERT INTO estpregunpolseg
                     (sseguro, cpregun, crespue, nmovimi, trespue)
              VALUES (vsseguro, 4073, piprima_np, 1, NULL);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE estpregunpolseg
               SET crespue = piprima_np
             WHERE sseguro = vsseguro
               AND cpregun = 4073
               AND nmovimi = 1;
      END;

      vpasexec := 21;

      --Seleccionamos cada uno de los riesgos activos de la póliza origen
      FOR y IN (SELECT   *
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND fanulac IS NULL
                ORDER BY nriesgo) LOOP
         --Obtenemos las preguntas de riesgos comunes entre el producto origen,
         --producto destino y el último movimiento de la póliza origen, por cada
         --uno de los riesgos activo.
         vind := vnriesgos.FIRST;
         vnriesgo := NULL;

         WHILE vind IS NOT NULL LOOP
            IF vnriesgos(vind).nrieold = y.nriesgo THEN
               vnriesgo := vnriesgos(vind).nrienew;
               EXIT;
            END IF;

            vind := vnriesgos.NEXT(vind);
         END LOOP;

         FOR x IN (SELECT cpregun
                     FROM pregunpro
                    WHERE sproduc = vseg.sproduc
                      AND cnivel = 'R'
                   UNION
                   SELECT cpregun
                     FROM pregunpro
                    WHERE sproduc = vsproduc_dest
                      AND cnivel = 'R'
                   UNION
                   SELECT cpregun
                     FROM pregunseg p1
                    WHERE sseguro = psseguro
                      AND nriesgo = vnriesgo
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM pregunseg p2
                                      WHERE sseguro = psseguro
                                        AND nriesgo = p1.nriesgo
                                        AND cpregun = p1.cpregun)) LOOP
            INSERT INTO estpregunseg
                        (cpregun, sseguro, nriesgo, nmovimi, crespue, trespue)
               SELECT x.cpregun, vsseguro, vnriesgo, 1, crespue, trespue
                 FROM pregunseg p1
                WHERE sseguro = psseguro
                  AND nriesgo = y.nriesgo
                  AND cpregun = x.cpregun
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregunseg p2
                                  WHERE sseguro = psseguro
                                    AND nriesgo = p1.nriesgo
                                    AND cpregun = p1.cpregun);
         END LOOP;

         vpasexec := 22;

         --Obtenemos las garantias de riesgos comunes entre el producto origen,
         --producto destino y el último movimiento de la póliza origen, por cada
         --uno de los riesgos activo.
         FOR x IN ((SELECT cgarant
                      FROM garanpro
                     WHERE sproduc = vseg.sproduc
                       AND cactivi = vseg.cactivi
                    UNION ALL
                    SELECT cgarant
                      FROM garanpro
                     WHERE sproduc = vseg.sproduc
                       AND cactivi = 0
                       AND NOT EXISTS(SELECT 1
                                        FROM garanpro g1
                                       WHERE g1.sproduc = vseg.sproduc
                                         AND g1.cactivi = vseg.cactivi))
                   INTERSECT
                   (SELECT cgarant
                      FROM garanpro
                     WHERE sproduc = vsproduc_dest
                       AND cactivi = vseg.cactivi
                    UNION ALL
                    SELECT cgarant
                      FROM garanpro
                     WHERE sproduc = vsproduc_dest
                       AND cactivi = 0
                       AND NOT EXISTS(SELECT 1
                                        FROM garanpro g1
                                       WHERE g1.sproduc = vsproduc_dest
                                         AND g1.cactivi = vseg.cactivi))
                   INTERSECT
                   SELECT cgarant
                     FROM garanseg p1
                    WHERE sseguro = psseguro
                      AND nriesgo = y.nriesgo
                      AND ffinefe IS NULL
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM garanseg p2
                                      WHERE sseguro = psseguro
                                        AND nriesgo = p1.nriesgo
                                        AND cgarant = p1.cgarant
                                        AND ffinefe IS NULL)) LOOP
            BEGIN
               SELECT ctipgar
                 INTO vctipgar
                 FROM garanpro
                WHERE cramo = vprod.cramo
                  AND cmodali = vprod.cmodali
                  AND ctipseg = vprod.ctipseg
                  AND ccolect = vprod.ccolect
                  AND cgarant = x.cgarant
                  AND cactivi = vseg.cactivi;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT ctipgar
                    INTO vctipgar
                    FROM garanpro
                   WHERE cramo = vprod.cramo
                     AND cmodali = vprod.cmodali
                     AND ctipseg = vprod.ctipseg
                     AND ccolect = vprod.ccolect
                     AND cgarant = x.cgarant
                     AND cactivi = 0;
            END;

            vpasexec := 23;

            IF x.cgarant = 6901 THEN
               INSERT INTO estgaranseg
                           (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                            ctarifa, icapital, precarg, iextrap, iprianu, ffinefe, cformul,
                            ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                            irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, crevalcar,
                            cgasgar, pgasadq, pgasadm, pdtoint, idtoint, feprev, fpprev,
                            percre, cmatch, tdesmat, pintfin, cref, cintref, pdif, pinttec,
                            nparben, nbns, tmgaran, cderreg, ccampanya, nversio, nmovima,
                            cageven, nfactor, nlinea, cfranq, nfraver, ngrpfra, ngrpgara,
                            nordfra, pdtofra, cmotmov, finider, falta, ctarman, cobliga,
                            ctipgar, itotanu)
                  SELECT x.cgarant, vnriesgo, 1, vsseguro, pfecha, norden, crevali, ctarifa,
                         picapfall_np, precarg, iextrap, piprima_np, ffinefe, cformul,
                         ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                         irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, crevalcar,
                         NULL, NULL, NULL, pdtoint, idtoint, feprev, fpprev, percre, cmatch,
                         tdesmat, pintfin, cref, cintref, pdif, pinttec, nparben, nbns,
                         tmgaran, cderreg, ccampanya, nversio, nmovima, cageven, nfactor,
                         nlinea, cfranq, nfraver, ngrpfra, ngrpgara, nordfra, pdtofra,
                         cmotmov, finider, falta, ctarman, 1, vctipgar, itotanu
                    FROM garanseg p1
                   WHERE sseguro = psseguro
                     AND nriesgo = y.nriesgo
                     AND cgarant = x.cgarant
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM garanseg p2
                                     WHERE sseguro = psseguro
                                       AND nriesgo = p1.nriesgo
                                       AND cgarant = p1.cgarant
                                       AND ffinefe IS NULL);
            ELSE
               vpasexec := 24;

               INSERT INTO estgaranseg
                           (cgarant, nriesgo, nmovimi, sseguro, finiefe, norden, crevali,
                            ctarifa, icapital, precarg, iextrap, iprianu, ffinefe, cformul,
                            ctipfra, ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali,
                            irevali, itarifa, itarrea, ipritot, icaptot, ftarifa, crevalcar,
                            cgasgar, pgasadq, pgasadm, pdtoint, idtoint, feprev, fpprev,
                            percre, cmatch, tdesmat, pintfin, cref, cintref, pdif, pinttec,
                            nparben, nbns, tmgaran, cderreg, ccampanya, nversio, nmovima,
                            cageven, nfactor, nlinea, cfranq, nfraver, ngrpfra, ngrpgara,
                            nordfra, pdtofra, cmotmov, finider, falta, ctarman, cobliga,
                            ctipgar, itotanu)
                  SELECT x.cgarant, vnriesgo, 1, vsseguro, pfecha, norden, crevali, ctarifa,
                         icapital, precarg, iextrap, iprianu, ffinefe, cformul, ctipfra,
                         ifranqu, irecarg, ipritar, pdtocom, idtocom, prevali, irevali,
                         itarifa, itarrea, ipritot, icaptot, ftarifa, crevalcar, NULL, NULL,
                         NULL, pdtoint, idtoint, feprev, fpprev, percre, cmatch, tdesmat,
                         pintfin, cref, cintref, pdif, pinttec, nparben, nbns, tmgaran,
                         cderreg, ccampanya, nversio, nmovima, cageven, nfactor, nlinea,
                         cfranq, nfraver, ngrpfra, ngrpgara, nordfra, pdtofra, cmotmov,
                         finider, falta, ctarman, 1, vctipgar, itotanu
                    FROM garanseg p1
                   WHERE sseguro = psseguro
                     AND nriesgo = y.nriesgo
                     AND cgarant = x.cgarant
                     AND nmovimi = (SELECT MAX(nmovimi)
                                      FROM garanseg p2
                                     WHERE sseguro = psseguro
                                       AND nriesgo = p1.nriesgo
                                       AND cgarant = p1.cgarant
                                       AND ffinefe IS NULL);
            END IF;
         END LOOP;

         vpasexec := 25;

         --Obtenemos las preguntas de garantia de riesgos comunes entre el producto origen,
         --producto destino y el último movimiento de la póliza origen, por cada
         --uno de los riesgos activo.
         FOR x IN ((SELECT cgarant, cpregun
                      FROM pregunprogaran
                     WHERE sproduc = vseg.sproduc
                       AND cactivi = vseg.cactivi
                    UNION ALL
                    SELECT cgarant, cpregun
                      FROM pregunprogaran
                     WHERE sproduc = vseg.sproduc
                       AND cactivi = 0
                       AND NOT EXISTS(SELECT 1
                                        FROM pregunprogaran pg1
                                       WHERE pg1.sproduc = vseg.sproduc
                                         AND pg1.cactivi = vseg.cactivi))
                   INTERSECT
                   (SELECT cgarant, cpregun
                      FROM pregunprogaran
                     WHERE sproduc = vsproduc_dest
                       AND cactivi = vseg.cactivi
                    UNION ALL
                    SELECT cgarant, cpregun
                      FROM pregunprogaran
                     WHERE sproduc = vsproduc_dest
                       AND cactivi = 0
                       AND NOT EXISTS(SELECT 1
                                        FROM pregunprogaran pg1
                                       WHERE pg1.sproduc = vsproduc_dest
                                         AND pg1.cactivi = vseg.cactivi))
                   INTERSECT
                   SELECT cgarant, cpregun
                     FROM pregungaranseg p1
                    WHERE sseguro = psseguro
                      AND nriesgo = y.nriesgo
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM pregungaranseg p2
                                      WHERE sseguro = psseguro
                                        AND nriesgo = p1.nriesgo
                                        AND cgarant = p1.cgarant
                                        AND cpregun = p1.cpregun)) LOOP
            INSERT INTO estpregungaranseg
                        (sseguro, nriesgo, cgarant, nmovimi, cpregun, crespue, nmovima,
                         finiefe, trespue)
               SELECT vsseguro, vnriesgo, x.cgarant, 1, x.cpregun, crespue, 1, pfecha,
                      trespue
                 FROM pregungaranseg p1
                WHERE sseguro = psseguro
                  AND nriesgo = y.nriesgo
                  AND cgarant = x.cgarant
                  AND cpregun = x.cpregun
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM pregungaranseg p2
                                  WHERE sseguro = psseguro
                                    AND nriesgo = p1.nriesgo
                                    AND cgarant = p1.cgarant
                                    AND cpregun = p1.cpregun);
         END LOOP;

         vpasexec := 26;

         -- Bug 24717 - MDS - 20/12/2012 : Anadir campo cestado
         INSERT INTO estbenespseg
                     (sseguro, nriesgo, cgarant, nmovimi, sperson, sperson_tit, finiben,
                      ffinben, ctipben, cparen, pparticip, cusuari, fmovimi, cestado)
            SELECT vsseguro, vnriesgo, cgarant, 1, sperson, sperson_tit, finiben, ffinben,
                   ctipben, cparen, pparticip, cusuari, fmovimi, cestado
              FROM benespseg p1
             WHERE sseguro = psseguro
               AND nriesgo = y.nriesgo
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM benespseg p2
                               WHERE sseguro = psseguro
                                 AND nriesgo = p1.nriesgo
                                 AND cgarant = 0
                                 AND sperson = p1.sperson
                                 AND sperson_tit = p1.sperson_tit)
               AND cgarant = 0;

         vpasexec := 27;

         FOR x IN (SELECT   cgarant
                       FROM estgaranseg
                      WHERE sseguro = vsseguro
                        AND nriesgo = vnriesgo
                        AND nmovimi = 1
                   ORDER BY cgarant) LOOP
            -- Bug 24717 - MDS - 20/12/2012 : Anadir campo cestado
            INSERT INTO estbenespseg
                        (sseguro, nriesgo, cgarant, nmovimi, sperson, sperson_tit, finiben,
                         ffinben, ctipben, cparen, pparticip, cusuari, fmovimi, cestado)
               SELECT vsseguro, vnriesgo, cgarant, 1, sperson, sperson_tit, finiben, ffinben,
                      ctipben, cparen, pparticip, cusuari, fmovimi, cestado
                 FROM benespseg p1
                WHERE sseguro = psseguro
                  AND nriesgo = y.nriesgo
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM benespseg p2
                                  WHERE sseguro = psseguro
                                    AND nriesgo = p1.nriesgo
                                    AND cgarant = p1.cgarant
                                    AND sperson = p1.sperson
                                    AND sperson_tit = p1.sperson_tit)
                  AND cgarant = x.cgarant;
         END LOOP;

         vpasexec := 28;

         --Obtenemos las clausulas de beneficiarios de los riesgos, comunes entre el producto origen,
         --producto destino y el último movimiento de la póliza origen, por cada
         --uno de los riesgos activos.
         FOR x IN (SELECT sclaben
                     FROM claubenpro
                    WHERE sproduc = vseg.sproduc
                   INTERSECT
                   SELECT sclaben
                     FROM claubenpro
                    WHERE sproduc = vsproduc_dest
                   INTERSECT
                   SELECT sclaben
                     FROM claubenseg p1
                    WHERE sseguro = psseguro
                      AND nriesgo = y.nriesgo
                      AND ffinclau IS NULL
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM claubenseg p2
                                      WHERE sseguro = psseguro
                                        AND nriesgo = p1.nriesgo
                                        AND sclaben = p1.sclaben
                                        AND ffinclau IS NULL)) LOOP
            INSERT INTO estclaubenseg
                        (nmovimi, sclaben, sseguro, nriesgo, finiclau, cobliga)
               SELECT 1, x.sclaben, vsseguro, vnriesgo, pfecha, 1
                 FROM claubenseg p1
                WHERE sseguro = psseguro
                  AND nriesgo = y.nriesgo
                  AND sclaben = x.sclaben
                  AND ffinclau IS NULL
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM claubenseg p2
                                  WHERE sseguro = psseguro
                                    AND nriesgo = p1.nriesgo
                                    AND sclaben = p1.sclaben
                                    AND ffinclau IS NULL);
         END LOOP;

         vpasexec := 29;

         --Obtenemos las clausulas especiales de los riesgos, comunes entre el producto origen,
         --producto destino y el último movimiento de la póliza origen, por cada
         --uno de los riesgos activos.
         FOR x IN (SELECT sclagen
                     FROM clausupro
                    WHERE cramo = vseg.cramo
                      AND cmodali = vseg.cmodali
                      AND ctipseg = vseg.ctipseg
                      AND ccolect = vseg.ccolect
                   INTERSECT
                   SELECT sclagen
                     FROM clausupro
                    WHERE cramo = vprod.cramo
                      AND cmodali = vprod.cmodali
                      AND ctipseg = vprod.ctipseg
                      AND ccolect = vprod.ccolect
                   INTERSECT
                   SELECT sclagen
                     FROM clausuesp p1
                    WHERE sseguro = psseguro
                      AND nriesgo = y.nriesgo
                      AND ffinclau IS NULL
                      AND nmovimi = (SELECT MAX(nmovimi)
                                       FROM clausuesp p2
                                      WHERE sseguro = psseguro
                                        AND nriesgo = p1.nriesgo
                                        AND sclagen = p1.sclagen
                                        AND ffinclau IS NULL)) LOOP
            INSERT INTO estclausuesp
                        (nmovimi, sseguro, cclaesp, nordcla, nriesgo, finiclau, sclagen,
                         tclaesp, ffinclau)
               SELECT 1, vsseguro, cclaesp, nordcla, vnriesgo, pfecha, x.sclagen, 1, NULL
                 FROM clausuesp p1
                WHERE sseguro = psseguro
                  AND nriesgo = y.nriesgo
                  AND sclagen = x.sclagen
                  AND ffinclau IS NULL
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM clausuesp p2
                                  WHERE sseguro = psseguro
                                    AND nriesgo = p1.nriesgo
                                    AND sclagen = p1.sclagen
                                    AND ffinclau IS NULL);
         END LOOP;
      --
      END LOOP;

      vpasexec := 30;

      --
      --Obtenemos las clausulas de la póliza, comunes entre el producto origen,
      --producto destino y el último movimiento de la póliza origen.
      FOR x IN (SELECT sclagen
                  FROM clausupro
                 WHERE cramo = vseg.cramo
                   AND cmodali = vseg.cmodali
                   AND ctipseg = vseg.ctipseg
                   AND ccolect = vseg.ccolect
                INTERSECT
                SELECT sclagen
                  FROM clausupro
                 WHERE cramo = vprod.cramo
                   AND cmodali = vprod.cmodali
                   AND ctipseg = vprod.ctipseg
                   AND ccolect = vprod.ccolect
                INTERSECT
                SELECT sclagen
                  FROM claususeg p1
                 WHERE sseguro = psseguro
                   AND ffinclau IS NULL
                   AND nmovimi = (SELECT MAX(nmovimi)
                                    FROM claususeg p2
                                   WHERE sseguro = psseguro
                                     AND sclagen = p1.sclagen
                                     AND ffinclau IS NULL)) LOOP
         INSERT INTO estclaususeg
                     (nmovimi, sseguro, sclagen, finiclau, nordcla)
            SELECT 1, vsseguro, x.sclagen, pfecha, nordcla
              FROM claususeg p1
             WHERE sseguro = psseguro
               AND sclagen = x.sclagen
               AND ffinclau IS NULL
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM claususeg p2
                               WHERE sseguro = psseguro
                                 AND sclagen = p1.sclagen
                                 AND ffinclau IS NULL);
      END LOOP;

      vpasexec := 31;
      --Grabamos interes tecnico
      vpinttec := pac_inttec.ff_int_producto(vseg.sproduc, 3, vseg.fefecto, 0);
      vpinttec2 := pac_inttec.ff_int_producto(vprod.sproduc, 3, vseg.fefecto, 0);

      IF vpinttec IS NOT NULL THEN
         INSERT INTO estintertecseg
                     (sseguro, fefemov, nmovimi, fmovdia, pinttec, ndesde, nhasta, ninntec)
              VALUES (vsseguro, pfecha, 1, pfecha, vpinttec, 0, 0, vpinttec2);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         ROLLBACK;
         RETURN SQLCODE;
   END f_crearpropuesta_sp;

-- Fi bug 19303 - JMC - 21/11/2011

   -- Bug 21706 - APD - 24/04/2012 - se crea la funcion
   FUNCTION f_capital_maximo_garantia_post(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug.14322:ASN:28/04/2010.ini
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcapital OUT NUMBER,
      pnmovima NUMBER DEFAULT 1)   -- Bug.14322:ASN:28/04/2010.fin)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vparam         VARCHAR2(10000)
         := 'psproduc = ' || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = '
            || pcgarant || '; psseguro = ' || psseguro || '; pnriesgo = ' || pnriesgo
            || '; pnmovimi = ' || pnmovimi;
      salir          EXCEPTION;
      garpro         garanpro%ROWTYPE;
      vicapmax       garanpro.icapmax%TYPE;
      num_err        NUMBER;
      vftarifa       estgaranseg.ftarifa%TYPE;
   BEGIN
      vpasexec := 1;

      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = pcgarant
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cactivi = 0;
      END;

      vpasexec := 2;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      IF garpro.ccapmax = 5 THEN   -- Calculado post-tarificacion (v.f.35)
         vpasexec := 3;

         BEGIN
            SELECT ftarifa
              INTO vftarifa
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgarant;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 103500;   -- Error al leer de la tabla GARANSEG
               RAISE salir;
         END;

         vpasexec := 4;
         num_err := pac_calculo_formulas.calc_formul(TRUNC(vftarifa), psproduc, garpro.cactivi,
                                                     pcgarant, pnriesgo, psseguro,
                                                     garpro.cclacap, vicapmax, pnmovimi, NULL,
                                                     1);
         vpasexec := 5;

         IF num_err <> 0 THEN
            RAISE salir;
         END IF;
      END IF;

      vpasexec := 5;
      pcapital := vicapmax;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, 'f_capital_maximo_garantia_post', vpasexec, vparam,
                     f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_capital_maximo_garantia_post', vpasexec, vparam,
                     SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_capital_maximo_garantia_post;

-- Bug 0026501 - MMS - 20130416
   FUNCTION f_capital_minimo_garantia_post(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug.14322:ASN:28/04/2010.ini
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcapital OUT NUMBER,
      pnmovima NUMBER DEFAULT 1)   -- Bug.14322:ASN:28/04/2010.fin)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vobj           VARCHAR2(100) := 'f_capital_minimo_garantia_post';
      vparam         VARCHAR2(10000)
         := 'psproduc = ' || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = '
            || pcgarant || '; psseguro = ' || psseguro || '; pnriesgo = ' || pnriesgo
            || '; pnmovimi = ' || pnmovimi;
      salir          EXCEPTION;
      garpro         garanpro%ROWTYPE;
      vicapmin       garanpro.icapmax%TYPE;
      num_err        NUMBER;
      vftarifa       estgaranseg.ftarifa%TYPE;
   BEGIN
      vpasexec := 1;

      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = pcgarant
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cactivi = 0;
      END;

      vpasexec := 2;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      IF garpro.ccapmin = 5 THEN   -- Calculado post-tarificacion (v.f.35)
         vpasexec := 3;

         BEGIN
            SELECT ftarifa
              INTO vftarifa
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgarant;
         EXCEPTION
            WHEN OTHERS THEN
               num_err := 103500;   -- Error al leer de la tabla GARANSEG
               RAISE salir;
         END;

         vpasexec := 4;
         num_err := pac_calculo_formulas.calc_formul(TRUNC(vftarifa), psproduc, garpro.cactivi,
                                                     pcgarant, pnriesgo, psseguro,
                                                     garpro.cclamin, vicapmin, pnmovimi, NULL,
                                                     1);
         vpasexec := 5;

         IF num_err <> 0 THEN
            RAISE salir;
         END IF;
      END IF;

      vpasexec := 5;
      pcapital := vicapmin;
      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vparam, f_axis_literales(num_err));
         RETURN num_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vparam, SQLERRM);
         RETURN 1000455;   -- Error no controlado.
   END f_capital_minimo_garantia_post;

-- Fin Bug 0026501 - MMS - 20130416

   -- Ini bug 21786 - APD - 18/05/2012
   /*************************************************************************
      FUNCTION f_valida_dep_garantias
      Función que recorrerá DEP_GARANTIAS y recuperará las funciones que de validación que se han definido
      para las garantías seleccionadas.
      pcgarant in number: código de la garantía
      psseguro in number: identificador del seguro
      pnriesgo in number: número del riesgo
      pnmovimi in number: número de movimiento
      psproduc in number: código de producto
      pcactivi in number: código de la actividad
      pmensa in out number: parámetro de entrada/salida
      return number: retorno de la función f_valida_garanproval
   *************************************************************************/
   FUNCTION f_valida_dep_garantias(
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER IS
      vnresult       NUMBER;
      vnvalidacio    NUMBER;
      vtparam        tab_error.tdescrip%TYPE;
      vobject        tab_error.tobjeto%TYPE := 'pk_nueva_produccion.f_valida_dep_garantias';
      vpasexec       NUMBER := 0;
      vnordval       NUMBER;

      -- Busca las validaciones en dep_garantias de aquellas garantias que estan seleccionadas
      -- y que la garantia de la cual depende tambien esté seleccionada (para el caso de aquellas
      -- garantias que se deben seleccionar si una garantia u otra garantia está seleccionada)
      CURSOR c_validaciones IS
         SELECT g.tvalgar
           FROM dep_garantias g
          WHERE g.cgarant = pcgarant
            AND g.sproduc = psproduc
            AND g.cactivi = pcactivi
            AND g.cgarpar IN(SELECT e.cgarant
                               FROM estgaranseg e
                              WHERE e.sseguro = psseguro
                                AND e.cobliga = 1
                                AND e.cgarant = g.cgarpar
                                AND e.nriesgo = NVL(pnriesgo, e.nriesgo))
         UNION ALL
         SELECT g.tvalgar
           FROM dep_garantias g
          WHERE g.cgarant = pcgarant
            AND g.sproduc = psproduc
            AND g.cactivi = 0
            AND g.cgarpar IN(SELECT e.cgarant
                               FROM estgaranseg e
                              WHERE e.sseguro = psseguro
                                AND e.cobliga = 1
                                AND e.cgarant = g.cgarpar
                                AND e.nriesgo = NVL(pnriesgo, e.nriesgo))
            AND NOT EXISTS(SELECT 1
                             FROM dep_garantias g1
                            WHERE g1.cgarant = pcgarant
                              AND g1.sproduc = psproduc
                              AND g1.cactivi = pcactivi
                              AND g1.cgarpar IN(SELECT e1.cgarant
                                                  FROM estgaranseg e1
                                                 WHERE e1.sseguro = psseguro
                                                   AND e1.cobliga = 1
                                                   AND e1.cgarant = g.cgarpar
                                                   AND e1.nriesgo = NVL(pnriesgo, e1.nriesgo)));
   BEGIN
      vtparam := 'pcgarant: ' || pcgarant || ' - ' || 'psseguro: ' || psseguro || ' - '
                 || 'pnriesgo: ' || pnriesgo || ' - ' || 'pnmovimi: ' || pnmovimi || ' - '
                 || 'psproduc: ' || psproduc || ' - ' || 'pcactivi: ' || pcactivi || ' - '
                 || 'pmensa: ' || pmensa;
      vpasexec := 1;
      pmensa := ' (' || ff_desgarantia(pcgarant, f_usu_idioma) || ')';

      FOR i IN c_validaciones LOOP
         vpasexec := 2;

         IF i.tvalgar IS NOT NULL THEN
            vnresult := pac_albsgt.f_tvalgar(i.tvalgar, 'EST', psseguro, pnriesgo, pnmovimi,
                                             pcgarant, pcactivi, vnvalidacio);
            vpasexec := 3;

            -- Si ha ocurrido un error retornamos
            IF NVL(vnresult, -1) != 0 THEN
               RETURN vnresult;
            END IF;

            vpasexec := 4;

            -- Si la garantía no ha superado la validación retornamos
            IF NVL(vnvalidacio, -1) != 0 THEN
               RETURN vnvalidacio;
            END IF;
         END IF;
      END LOOP;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vtparam, SQLERRM);
         RETURN 9901995;
   END f_valida_dep_garantias;

-- Fin bug 21786 - APD - 18/05/2012

   -- Bug 0026501 - MMS - 20130416
   FUNCTION f_capital_minimo_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER                   /****************,
                         pcicapmin IN OUT NUMBER*/)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vobj           VARCHAR2(100) := 'pk_nueva_produccion.f_capital_minimo_garantia';
      vparam         VARCHAR2(10000)
         := 'psproduc = ' || psproduc || '; pcactivi = ' || pcactivi || '; pcgarant = '
            || pcgarant || '; psseguro = ' || psseguro || '; pnriesgo = ' || pnriesgo
            || '; pnmovimi = ' || pnmovimi;
      garpro         garanpro%ROWTYPE;
      vicapmin       garanpro.icapmin%TYPE;
      num_err        NUMBER;
      vftarifa       estgaranseg.ftarifa%TYPE;
   BEGIN
      vpasexec := 1;

      -- Bug 9699 - APD - 08/04/2009 - primero se ha de buscar para la actividad en concreto
      -- y si no se encuentra nada ir a buscar a PREGUNPROGARAN para la actividad cero
      BEGIN
         SELECT *
           INTO garpro
           FROM garanpro
          WHERE sproduc = psproduc
            AND cgarant = pcgarant
            AND cactivi = pcactivi;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT *
              INTO garpro
              FROM garanpro
             WHERE sproduc = psproduc
               AND cgarant = pcgarant
               AND cactivi = 0;
      END;

      vpasexec := 2;

      -- Bug 9699 - APD - 08/04/2009 - Fin
      -- Utilizamos los campos garanpro.ip_icapmax, y garanpro.ip_icapmin porque el capital máximo
      -- puede ir cambiando ON-LINE (depende del tipo de capital, etc...)
      IF garpro.ccapmin = 1 THEN   -- Fijo
         vpasexec := 3;
         RETURN garpro.icapmin;
      ELSIF garpro.ccapmin = 2 THEN   -- Depende de otro
         vpasexec := 4;

         -- Cuando el capital MIN depende de otro, entendemos que depende del capital contratado en GARANSEG
         BEGIN
            SELECT icapital * NVL(garpro.pcapdep, 100) / 100
              INTO vicapmin
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgardep;
         EXCEPTION
            WHEN OTHERS THEN
               vicapmin := NULL;
         END;

         RETURN vicapmin;
      ELSIF garpro.ccapmin = 4 THEN   -- Calculado (v.f.35)
         vpasexec := 5;

         BEGIN
            SELECT ftarifa
              INTO vftarifa
              FROM estgaranseg
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi
               AND nriesgo = pnriesgo
               AND cgarant = garpro.cgarant;
         EXCEPTION
            WHEN OTHERS THEN
               vftarifa := NULL;
         END;

         vpasexec := 6;
         num_err := pac_calculo_formulas.calc_formul(TRUNC(vftarifa), psproduc, garpro.cactivi,
                                                     pcgarant, pnriesgo, psseguro,
                                                     garpro.cclamin, vicapmin, pnmovimi, NULL,
                                                     1);
         vpasexec := 7;

         IF num_err <> 0 THEN
            vicapmin := NULL;
         END IF;

         RETURN vicapmin;
      ELSE   -- Ilimitado
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vparam, SQLERRM);
         RETURN NULL;   -- Error no controlado.
   END f_capital_minimo_garantia;
-- Fin Bug 0026501 - MMS - 20130416
END pk_nueva_produccion;
/
