create or replace PACKAGE BODY pac_validaciones_sin AS
   /******************************************************************************
      NOMBRE:      PAC_VALIDACIONES_SIN
      PROPÓSITO: Funciones para la validación de siniestros

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/02/2009   XPL i XVM        1. Creación del package.
      2.0        02/02/2010   AMC              2. Bug 12207. Se añade la función f_calcimporteres
      3.0        26/04/2010   DRA              3. 0014281: AGA014 - Validacions reserves per sinistres de baixa
      4.0        27/05/2010   AMC              4. Bug 14608 .Se añaden nuevos parametros  a f_detpago
      5.0        18/06/2010   DRA              5. 0015050: CEM210 - Traspasos: Los traspasos de salida tienen que tener retención 0
      6.0        22/06/2010   DRA              6. 0015131: CEM800 - Siniestros de PPA que tienen el pago duplicado
      7.0        28/06/2010   DRA              7. 0015171: AGA202 - Validacions als pagaments de sinistres
      8.0        07/06/2010   AMC              8. Bug 15260 .Se añaden los campos pccompani y pcpolcia a f_trasini
      9.0        10/08/2010   JRH              9. BUG 0015669 : Campos nuevos
     10.0        26/10/2010   ICV             10. 0016280: GRC - Gestión de siniestro. Modificación de pago II
     11.0        22/11/2010   JRH             29. 16455: ENSA101 - Gravació de destinatari
     12.0        10/01/2011   SMF             11. 16683: AGA003 - destinatario automatico en siniestros de rentas y bajas
     13.0        21/01/2011   RSC             13. 17354: INCLOURE FACTURES DESPESES JUDICIS EN SINISTRES
     14.0        14/02/2011   JRH             14. 0017247: ENSA103 - Instalar els web-services als entorns CSI
     15.0        16/02/2011   JMP             15. 17660: CRE - F_RESTRAMI: Añadir la agrupación 5 (Salud) en comprobación productos vida
     16.0        16/03/2011   JMF             16. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
     17.0        26/04/2011   APD             17. 0018286: Estudiar si es necesario informar el siniestro en pagosrenta
     18.0        17/06/2011   APD             18. 0018670: ENSA102- Permitir escoger las formas posibles de prestación a partir del tipo de siniestro
     19.0        07/06/2011   SRA             19. 0018554: LCOL701 - Desarrollo de Modificación de datos cabecera siniestro y ver histórico (BBDD).
     20.0        21/06/2011   JMF             20. 0018812 ENSA102-Proceso de alta de prestación en forma de renta actuarial
     21.0        04/08/2011   ICV             21. 0019172: SIN - Transiciones de estados de pagos permitidas
     22.0        05/10/2011   JMC             22. 0019601: Nota 94118
     23.0        06/10/2011   JMC             22. 0019601: LCOL_S001-SIN - Subestado del pago
     24.0        22/11/2011   MDS             11. 0019821: LCOL_S001-SIN - Tramitación judicial
     25.0        13/01/2012   JMF             25. 0020610: LCOL_S001-SIN - Valor de reserva máximo el del capital
     25.0        16/01/2012   JMF             25. 0020610: LCOL_S001-SIN - Valor de reserva máximo el del capital
     26.0        16/01/2012   JMP             26. 0018423: LCOL705 - Multimoneda
     27.0        19/01/2012   JMP             27. 0020014: LCOL_S001-SIN - Reservas y pagos en tramitaciones cerradas
     28.0        14/02/2012   JMP             28. 21307/107043: Comprobación de si hay documentación obligatoria pendiente de adjuntar
     29.0        16/05/2012   JMF             0022243 LCOL_S001-SIN - Impedir siniestros duplicados en el alta de siniestros (ID=4561)
     30.0        30/05/2012   ASN             0022108: MDP_S001-SIN - Movimiento de trámites
     31.0        19/06/2012   ASN             0022108: MDP_S001-SIN - Movimiento de trámites
     32.0        20/09/2012   JMF             0023741: LCOL_S001-SIN - Límite tramitadores alta siniestros (Id=5044)
     33.0        31/10/2012   ASN             0024491: MDP_S001-SIN - Control siniestros duplicados
     34.0        25/07/2013   RCL             34. 0027739: LCOL895-SIN - No validación reserva respecto a capital garantía
     35.0        13/08/2013   ASN             0025537: RSA000 - Gestión de incidencias (0150927/0150917)
     36.0        12/09/2013   JMF             0025651: RSA003 - Incidencias detectadas en el módulo de siniestros
     37.0        06/11/2013   ASN             0024708/0157228 (POSPG500)-  No validar reserva en alta detalle pago
     38.0        28/01/2014   JTT             38. 28830: Afegim la funcio F_get_cartera_pendiente
     39.0        14/03/2014   JTT             39. 29224: Corregim la funcio F_repetido per validar unicament el dia, sense hores
     40.0        21/03/2014   JTT             40. 29804: Corregim la funcion F_movpago per no validar el limit del uuari en els moviments de anul.lacio
     41.0        24/03/2014   NSS             41. 0024637/0147756: (POSAN500-AN-Sin) Analisis Desarrollo: Siniestros
     42.0        01/04/2014   JTT             42. 30843/171584: Validacion de fecha de inicio fin solo para las reservas indemnizatorias
     43.0        09/04/2014   NSS             43. 0030935: POSPG500-Control de alta de siniestros duplicados según garantía
     44.0        22/04/2014   NSS             44. 0029989/165377: LCOL_S001-SIN - Rechazo de tramitación única
     45.0        25/04/2014   NSS             45. 0030882/0173358: POSPG500-Información del asegurado de productos innominados en alta de siniestros
     46.0        23/07/2014   JTT             46. 0029224/180509: Anulamos la funcion f_val_aseg_innominado
     47.0        04/11/2014   JTT             47. 0033298/190844: Correccion de las funciones F_movtrami, F_movpago i F_movtramte: al recuperar el nivel de pagos
     48.0        23/12/2014   DCT             48. 0028311: POSSIN - AJUSTES SEGUN FICHAS DE SINIESTROS
     49.0        02/03/2015   JTT             49. 0034909/198897: Fecha de formalización de siniestros (f_validar_documento_cierre)
     50.0        12/03/2015   JTT             50. 0034909/200538: Fecha de formalización de siniestros, eliminamos la validación del movimiento de pago (F_movpago)
     51.0        23/04/2015   JTT             51. 0035654/203127: Modificaciones sobre las validaciones de renta diaria
     52.0        30/04/2015   JTT             52. 0035654/203633: Modificaciones sobre las validaciones de renta diaria, solapamiento de periodos
     53.0        13/05/2015   JDS             53. 0035654/204138: Validaciones previsa al alta del siniestro sobre la fechas de la garantia de renta diaria
     54.0        15/04/2015   YDA             54. 34989/202058: En f_cabecerapago se adiciona la validación de clasificación FATCA para beneficiarios
     55.0        05/10/2015   BLA             55. 37903/215023: En f_restrami se adiciona la validación  NVL para el parametro v_gar_renta
     56.0        25/01/2016   JAA             56. 39228/221317: En f_valida_garantia se agrega la validación de los parámtetros SIN_BAJA_DIAS y SIN_BAJA_EVENTOS
     57.0        23/06/2016    AP             57. CONF-85 Fecha real de Ocurrencia
	 58.0        26/01/2018   ACL             58. 001587 - Se quita las validaciones del campo FECHAPP "Fecha real ocurrencia" ya que es un campo informativo.
	 59.0        16/04/2018   ACL             59. 000424 - Se agrega el modo "PRE_SINIESTROS" en la validación si ya existe un siniestro para una póliza de cumplimiento.
     60.0        25/04/2019   ECP             60. IAXIS-3178. CUBO CONTABILIDAD
	 61.0        08/01/2020   IRDR            61. IAXIS-6242 Validadores Indemnización - Se crea una función para que devuelva valores de (reserva, constitución, aumento, liberación, disminución)   
   ******************************************************************************/
   e_error EXCEPTION;

   /*************************************************************************
      FUNCTION f_cabecerasini
         Valida la capçalera del sinistre
         param in pfsinies     : data sinistre
         param in pfnotifi     : data notificació
         param in pccausin     : codi causa sinistre
         param in pcmotsin     : codi motiu sinistre
         param in psseguro    : secuencia seguro
          param IN pcnivel  : Nivel
          param IN psperson2 : Persona relacionada
         param IN pnsinies : numero siniestro
         param IN pmodo    : modo antalla
         param IN piperit  : coste aproximado
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_cabecerasini(pfsinies    IN DATE,
                           pfnotifi    IN DATE,
                           pccausin    IN NUMBER,
                           pcmotsin    IN NUMBER,
                           psseguro    IN NUMBER,
                           pcnivel     IN NUMBER DEFAULT NULL,
                           psperson2   IN NUMBER DEFAULT NULL,
                           pnsinies    IN NUMBER DEFAULT NULL,
                           pmodo       IN VARCHAR2, -- 24434:ASN:05/11/2012
                           piperit     IN NUMBER, -- 24434:ASN:05/11/2012
                           ptemaildec  IN VARCHAR2, --24869:NSS:11/12/2012
                           picapital   IN NUMBER, -- BUG 0024869 - 14/12/2012 - NSS
                           pctipdec    IN NUMBER, -- 0025537:ASN:13/08/2013
                           ptgarantias IN t_iax_garansini, -- BUG 30935 - 09/04/2014 - NSS
                           pfechapp    IN DATE DEFAULT NULL, -- CONF-85 AP
                           pterror     OUT tab_error.terror%TYPE)
      RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_cabecerasini';
      vparam      VARCHAR2(500) := 'parámetros - pfsinies: ' || pfsinies ||
                                   ' pfnotifi:' || pfnotifi || ' pccausin:' ||
                                   pccausin || ' pcmotsin:' || pcmotsin ||
                                   ' psseguro:' || psseguro || ' pnsinies:' ||
                                   pnsinies;
      vpasexec    NUMBER(5) := 0;
      vfefecto    seguros.fefecto%TYPE;
      vfvencim    seguros.fvencim%TYPE;
      vfanulac    seguros.fanulac%TYPE;
      vncertif    seguros.ncertif%TYPE; -- 29224/174406:NSS:09/05/2014
      -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
      vnum NUMBER;
      -- Fi BUG 0015669 - 08/2010 - JRH
      vsproduc seguros.sproduc%TYPE; -- Bug 18670 - APD - 16/06/2011
      vcactivi seguros.cactivi%TYPE; -- Bug 18670 - APD - 16/06/2011
      vcgarant garanpro.cgarant%TYPE; -- Bug 18670 - APD - 16/06/2011
      vnumsini sin_gar_causa.numsini%TYPE;
      -- Bug 18670 - APD - 16/06/2011
      vcempres  seguros.cempres%TYPE; -- Bug 0022243 - 16/05/2012 - JMF
      d_abierto sin_movsiniestro.festsin%TYPE;
      -- Bug 0022243 - 16/05/2012 - JMF
      d_cerrado sin_movsiniestro.festsin%TYPE;
      -- Bug 0022243 - 16/05/2012 - JMF
      verror       NUMBER;
      hay_formulas NUMBER; -- 24434:ASN:05/11/2012
      vctipsin     NUMBER; -- 0025537:ASN:13/08/2013
      v_cramo      NUMBER; -- BUG 30935 - 09/04/2014 - NSS
      v_cmodali    NUMBER; -- BUG 30935 - 09/04/2014 - NSS
      v_ctipseg    NUMBER; -- BUG 30935 - 09/04/2014 - NSS
      v_ccolect    NUMBER; -- BUG 30935 - 09/04/2014 - NSS
      v_cactivi    NUMBER; -- BUG 30935 - 09/04/2014 - NSS
      v_cantidad   NUMBER;

   BEGIN
      vpasexec := 100;

      --Comprovació dels parámetres d'entrada
      IF pfsinies IS NULL
      THEN
         RETURN 9001376;
      END IF;

      IF pfnotifi IS NULL
      THEN
         RETURN 9001377;
      END IF;

      IF pccausin IS NULL
      THEN
         RETURN 9001378;
      END IF;

      IF pcmotsin IS NULL
      THEN
         RETURN 9001379;
      END IF;

      IF psseguro IS NULL
      THEN
         RETURN 111995; --Es obligatorio informar el número de seguro
      END IF;

      --Bug 24869 - NSS- 11/12/2012
      IF ptemaildec NOT LIKE '%@%'
      THEN
         RETURN 9904619;
      END IF;

      IF piperit > picapital
      THEN
         RETURN 9904631;
      END IF;

      --Fin Bug 24869 - NSS- 11/12/2012

      -- Bug 11834 - 26/11/2009 - AMC
      BEGIN
         -- Bug 18670 - APD - 16/06/2011 - se añaden el sproduc y cactivi
         -- Bug 0022243 - 16/05/2012 - JMF: afegir cempres
         vpasexec := 110;

         SELECT TRUNC(fefecto),
                TRUNC(fvencim),
                TRUNC(fanulac),
                sproduc,
                cactivi,
                cempres,
                ncertif -- 29224/174406:NSS:09/05/2014
           INTO vfefecto,
                vfvencim,
                vfanulac,
                vsproduc,
                vcactivi,
                vcempres,
                vncertif -- 29224/174406:NSS:09/05/2014
           FROM seguros
          WHERE sseguro = psseguro;
         -- Fin Bug 18670 - APD - 16/06/2011
      EXCEPTION
         WHEN OTHERS THEN
            vfefecto := NULL;
            vfvencim := NULL;
            vfanulac := NULL;
      END;

      vpasexec := 120;

      IF (TRUNC(pfsinies) < vfefecto)
      THEN
         RETURN 109925;
      ELSIF (vfvencim IS NOT NULL AND TRUNC(pfsinies) >= vfvencim)
      THEN
         RETURN 110490;
      ELSIF (vfanulac IS NOT NULL AND TRUNC(pfsinies) >= vfanulac)
      THEN
         RETURN 9900747;
      END IF;

      --Fi Bug 11834 - 26/11/2009 - AMC
      vpasexec := 130;

      IF TRUNC(pfsinies) > TRUNC(pfnotifi)
      THEN
         RETURN 9001381;
      END IF;

      IF TRUNC(pfsinies) > TRUNC(f_sysdate)
      THEN
         RETURN 9001382;
      END IF;

      IF TRUNC(pfnotifi) > TRUNC(f_sysdate)
      THEN
         RETURN 9001383;
      END IF;

	  -- Ini Bug 001587 - 26/01/2018 - ACL
      --Fi CONF-85 - 23/06/2016 - AP
     /* IF TRUNC(pfechapp) > TRUNC(pfnotifi)
      THEN
         RETURN 9001381;
      END IF;

      IF TRUNC(pfechapp) > TRUNC(f_sysdate)
      THEN
         RETURN 9001382;
      END IF;

      IF (TRUNC(pfechapp) < vfefecto)
      THEN
         RETURN 109925;
      -- CONF-1139 - 10/10/2017 JGONZALEZ
      -- ELSIF (vfvencim IS NOT NULL AND TRUNC(pfechapp) >= vfvencim)
      -- THEN
      --    RETURN 110490;
      ELSIF (vfanulac IS NOT NULL AND TRUNC(pfechapp) >= vfanulac)
      THEN
         RETURN 9900747;
      END IF; */
      -- Fi CONF-85 - 23/06/2016 - AP
	  -- Fin Bug 001587 - 26/01/2018 - ACL
      --      -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
      --      IF NVL(pcnivel, 1) = 1 THEN
      --         IF psperson2 IS NOT NULL THEN
      --            RETURN 9901377;
      --         END IF;
      --      END IF;
      IF NVL(pcnivel, 1) > 1
      THEN
         vpasexec := 140;

         SELECT COUNT(*)
           INTO vnum
           FROM sin_siniestro --Ha de existir algún siniestro
          WHERE sseguro = psseguro;

         IF vnum = 0
         THEN
            RETURN 9901378;
         END IF;
      END IF;

      vpasexec := 150;
      --      IF psperson2 IS NOT NULL THEN
      --         SELECT COUNT(*)
      --           INTO vnum
      --           FROM sin_siniestro s, sin_tramita_destinatario d   --Ha de existir algún siniestro
      --          WHERE s.sseguro = psseguro
      --            AND s.nsinies = d.nsinies
      --            AND d.sperson = psperson2;

      --         IF vnum = 0 THEN
      --            RETURN 9901379;
      --         END IF;
      --      END IF;
      vpasexec := 160;

      SELECT COUNT(*)
        INTO vnum
        FROM detvalores
       WHERE cvalor = 1017
         AND catribu = NVL(pcnivel, 1);

      IF vnum = 0
      THEN
         RETURN 9901380;
      END IF;

      -- Fi BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)

      -- Bug 18670 - APD - 16/06/2011 - si el CCAUSIN CMOTSIN del siniestro tienen un valor NUMSINI
      -- no nulo en NUMSINI para el producto, se asegure de que para ese CCAUSIN CMOTSIN no se
      -- vaya a superar el número de siniestros por póliza (mirando cuantos siniestros con el
      -- mismo CCAUSIN CMOTSIN iguales estén dados ya de alta para la póliza (en estado 0,1 o 4)).
      BEGIN
         vpasexec := 170;

         SELECT numsini
           INTO vnumsini
           FROM sin_gar_causa
          WHERE sproduc = vsproduc
            AND cactivi = vcactivi
               -- AND cgarant = vcgarant       -- De momento no se tiene en cuenta la garantia
            AND ccausin = pccausin
            AND cmotsin = pcmotsin;
      EXCEPTION
         WHEN too_many_rows THEN
            vnumsini := NULL;
      END;

      IF NVL(vnumsini, 0) > 0
      THEN
         -- se cuentan el numero de siniestros que hay dados de alta para la poliza (en estado 0,1 o 4)
         -- con el mismo ccausin y cmotsin
         -- detvalores 6 = Estado del siniestro
         -- 0.- Abierto
         -- 1.- Terminado
         -- 4.- Reabierto
         vpasexec := 180;

         SELECT COUNT(*)
           INTO vnum
           FROM sin_siniestro    s,
                sin_movsiniestro m
          WHERE s.sseguro = psseguro
            AND s.ccausin = pccausin
            AND s.cmotsin = pcmotsin
            AND s.nsinies = m.nsinies
            AND m.nmovsin = (SELECT MAX(m2.nmovsin)
                               FROM sin_movsiniestro m2
                              WHERE m.nsinies = m2.nsinies)
            AND m.cestsin IN (0, 1, 4);

         -- Si el numero de siniestros por poliza para una causa y motivo determinado, supera
         -- el numero de siniestros permitidos para una causa y motivo, entonces error
         IF vnum >= vnumsini
         THEN
            RETURN 9902138;
            -- No se permite dar de alta más siniestros a la póliza para la misma causa y motivo.
         END IF;
      END IF;

      -- fin Bug 18670 - APD - 16/06/2011

      -- ini bug 29224/174406:NSS:09/05/2014
      IF vncertif = 0 AND
         f_parproductos_v(vsproduc, 'ADMITE_CERTIFICADOS') = 1
      THEN
         RETURN 9906748;
      END IF;

      -- fin bug 29224/174406:NSS:09/05/2014

      -- ini Bug 0022243 - 16/05/2012 - JMF
      vpasexec := 190;

      --INI BUG 0030882/0173358:NSS:25/04/2014 POSPG500-Información del asegurado de productos innominados en alta de siniestros
      IF NVL(f_parproductos_v(vsproduc, 'SIN_VALCAUSAUNICPROD'), -1) = -1
      THEN
         IF pac_parametros.f_parempresa_n(vcempres, 'SIN_VALCAUSAUNICA') = 1
         THEN
            -- No permitir siniestro con la misma causa en fecha
            vpasexec := 200;

            -- 24491:ASN:31/10/2012 ini
            /*
            SELECT MIN(b.festsin), MAX(c.festsin)
              INTO d_abierto, d_cerrado
              FROM sin_siniestro a, sin_movsiniestro b, sin_movsiniestro c
             WHERE a.sseguro = psseguro
               AND a.ccausin = pccausin
               AND(NVL(pnsinies, -1) = -1
                   OR a.nsinies <> pnsinies)
               AND b.nsinies(+) = a.nsinies
               AND b.cestsin(+) = 0
               AND c.nsinies(+) = a.nsinies
               AND c.cestsin(+) = 1;

            IF d_abierto IS NOT NULL THEN
               RETURN 9902112;
            ELSIF d_abierto IS NOT NULL
                  AND d_cerrado IS NOT NULL
                  AND pfsinies >= d_abierto
                  AND pfsinies <= d_cerrado THEN
               RETURN 9902112;
            END IF; */

            -- 25020:ASN:07/12/2012 ini
            --         verror := pac_validaciones_sin.f_repetido(psseguro, pfsinies, pccausin, NULL);
            IF pmodo = 'ALTA_SINIESTROS'
            THEN
               verror := pac_validaciones_sin.f_repetido(psseguro,
                                                         pfsinies,
                                                         pccausin,
                                                         NULL);
            ELSE
               verror := pac_validaciones_sin.f_repetido(psseguro,
                                                         pfsinies,
                                                         pccausin,
                                                         pnsinies);
            END IF;

            -- 25020:ASN:07/12/2012 fin
            IF verror <> 0
            THEN
               RETURN verror;
            END IF;
            -- 24491:ASN:31/10/2012  fin

            -- ini Bug 0025651 - 12/09/2013 - JMF
         ELSIF pac_parametros.f_parempresa_n(vcempres, 'SIN_VALCAUSAUNICA') = 3
         THEN
            -- No permitir siniestro con el mismo tipo de causa
            vpasexec := 208;

            IF pmodo = 'ALTA_SINIESTROS'
            THEN
               verror := pac_validaciones_sin.f_repetido_ctipsin(psseguro,
                                                                 pfsinies,
                                                                 pccausin,
                                                                 NULL);
            ELSE
               verror := pac_validaciones_sin.f_repetido_ctipsin(psseguro,
                                                                 pfsinies,
                                                                 pccausin,
                                                                 pnsinies);
            END IF;

            IF verror <> 0
            THEN
               RETURN verror;
            END IF;
            -- fin Bug 0025651 - 12/09/2013 - JMF
         END IF;
      ELSIF f_parproductos_v(vsproduc, 'SIN_VALCAUSAUNICPROD') = 1
      THEN
         IF pmodo = 'ALTA_SINIESTROS'
         THEN
            verror := pac_validaciones_sin.f_repetido(psseguro,
                                                      pfsinies,
                                                      pccausin,
                                                      NULL);
         ELSE
            verror := pac_validaciones_sin.f_repetido(psseguro,
                                                      pfsinies,
                                                      pccausin,
                                                      pnsinies);
         END IF;

         -- 25020:ASN:07/12/2012 fin
         IF verror <> 0
         THEN
            RETURN verror;
         END IF;
      ELSIF f_parproductos_v(vsproduc, 'SIN_VALCAUSAUNICPROD') = 3
      THEN
         IF pmodo = 'ALTA_SINIESTROS'
         THEN
            verror := pac_validaciones_sin.f_repetido_ctipsin(psseguro,
                                                              pfsinies,
                                                              pccausin,
                                                              NULL);
         ELSE
            verror := pac_validaciones_sin.f_repetido_ctipsin(psseguro,
                                                              pfsinies,
                                                              pccausin,
                                                              pnsinies);
         END IF;

         IF verror <> 0
         THEN
            RETURN verror;
         END IF;
      END IF;

      --END BUG 0030882/0173358:NSS:25/04/2014 POSPG500-Información del asegurado de productos innominados en alta de siniestros

      -- Bug 0030935 - 09/04/2014 - NSS
      SELECT seg.cramo,
             seg.cmodali,
             seg.ctipseg,
             seg.ccolect,
             seg.cactivi
        INTO v_cramo,
             v_cmodali,
             v_ctipseg,
             v_ccolect,
             v_cactivi
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      IF NVL(f_parproductos_v(vsproduc, 'SIN_VALCAUSAUNICPROD'), -1) <> 0
      THEN
         -- 0030882/0173358:NSS:25/04/2014
         IF ptgarantias IS NOT NULL AND
            ptgarantias.count > 0
         THEN
            FOR i IN ptgarantias.first .. ptgarantias.last
            LOOP
               IF ptgarantias.exists(i)
               THEN
                  IF f_pargaranpro_v(v_cramo,
                                     v_cmodali,
                                     v_ctipseg,
                                     v_ccolect,
                                     v_cactivi,
                                     ptgarantias(i).cgarant,
                                     'SINIESTRO_REPE') = 0
                  THEN
                     -- No permitir siniestro con la misma garantia
                     verror := pac_validaciones_sin.f_repetido_garantia(psseguro,
                                                                        ptgarantias(i)
                                                                        .cgarant,
                                                                        ptgarantias(i)
                                                                        .tgarant,
                                                                        pterror);

                     IF verror <> 0
                     THEN
                        RETURN verror;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      -- fin Bug 0030935 - 09/04/2014 - NSS
      vpasexec := 210;

      -- fin Bug 0022243 - 16/05/2012 - JMF

      -- 24434:ASN:05/11/2012 ini
      -- Si ni hemos entrado en modo presiniestro y no hay formulacion, piperit no puede ser 0
      IF pmodo = 'ALTA_SINIESTROS'
      THEN
         IF NVL(piperit, 0) < 0.01
         THEN
            SELECT COUNT(*)
              INTO hay_formulas
              FROM sin_for_causa_motivo
             WHERE ctipdes = 0
               AND ccampo = 'IVALSIN'
               AND scaumot IN (SELECT scm.scaumot
                                 FROM sin_causa_motivo     scm,
                                      sin_gar_causa_motivo sgcm
                                WHERE scm.ccausin = pccausin
                                  AND scm.cmotsin = pcmotsin
                                  AND scm.scaumot = sgcm.scaumot
                                  AND sgcm.sproduc = vsproduc
                                  AND sgcm.cactivi = vcactivi);

            IF hay_formulas = 0
            THEN
               RETURN 9904479;
            END IF;
         END IF;
      END IF;

      -- 24434:ASN:05/11/2012 fin

      -- 0025537:ASN:13/08/2013 ini
      IF NVL(pctipdec, 0) = 1
      THEN
         -- si el declarante es el asegurado
         SELECT DISTINCT ctipsin
           INTO vctipsin
           FROM sin_causa_motivo     s,
                seguros              se,
                sin_gar_causa_motivo sg
          WHERE s.ccausin = pccausin
            AND s.cmotsin = pcmotsin
            AND se.sproduc = sg.sproduc
            AND se.sseguro = psseguro
            AND sg.scaumot = s.scaumot;

         IF vctipsin = 1
         THEN
            -- si es siniestro de muerte
            RETURN 9905837; -- Tipo declarante erroneo
         END IF;
      END IF;

	  -- INI Inc. 424 - ACL - 16/04/2018
      IF pmodo in ('ALTA_SINIESTROS', 'PRE_SINIESTROS') THEN
	  -- FIN Inc. 424 - ACL - 16/04/2018
         SELECT COUNT(*) cantidad
          INTO v_cantidad
          FROM sin_siniestro n,
               seguros       s
         WHERE n.sseguro = s.sseguro
           AND s.cramo = 801
           AND s.sseguro = psseguro;

         IF v_cantidad > 0 THEN
            RETURN 89906057;
         END IF;
      END IF;

      -- 0025537:ASN:13/08/2013 fin
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001380; --Error validar sinistre
   END f_cabecerasini;

   /*************************************************************************
      FUNCTION f_movsini
         Valida el moviment del sinistre
         param in pcestsin     : codi estat sinistre
         param in pfestsin     : data estat sinistre
         param in pcunitra     : codi unitat tramitadora
         param in pctramitad   : codi tramitador
         return                : 0 -> Tot correcte
                                 1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movsini(pcestsin   IN NUMBER,
                      pfestsin   IN DATE,
                      pcunitra   IN VARCHAR2,
                      pctramitad IN VARCHAR2) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_movsini';
      vparam      VARCHAR2(500) := 'parámetros - pcestsin: ' || pcestsin ||
                                   ' pfestsin:' || pfestsin || ' pcunitra:' ||
                                   pcunitra || ' pctramitad:' || pctramitad;
      vpasexec    NUMBER(5) := 1;
      vctramitad  VARCHAR2(4);
      vctramitpad VARCHAR2(4);
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pcestsin IS NULL
      THEN
         RETURN 9001399; -- Estat del sinistre obligatori
      END IF;

      IF TRUNC(pfestsin) <> TRUNC(f_sysdate)
      THEN
         RETURN 9001398;
         --La data de l''estat ha de ser igual a la data actual
      END IF;

      IF pctramitad IS NULL
      THEN
         RETURN 9001400; --Tramitador obligatori
      ELSE
         BEGIN
            SELECT ctramitad
              INTO vctramitad
              FROM sin_codtramitador
             WHERE cusuari = f_user
               AND ctiptramit = 3;
         EXCEPTION
            WHEN no_data_found THEN
               RETURN 9001401; --No s'ha trobat el Tramitador
         END;

         IF pctramitad <> vctramitad
         THEN
            RETURN 9001402; --Tramitador incorrecte
         END IF;
      END IF;

      IF pcunitra IS NULL
      THEN
         RETURN 9001403; --Unitat Tramitadora obligatoria
      ELSE
         BEGIN
            SELECT ctramitpad
              INTO vctramitpad
              FROM sin_redtramitador
             WHERE ctramitad = vctramitad
               AND ctiptramit = 2;
         EXCEPTION
            WHEN no_data_found THEN
               RETURN 9001404; --No s'ha trobat la Unitat Tramitadora
         END;

         IF pcunitra <> vctramitpad
         THEN
            RETURN 9001405; --Unitat Tramitadora incorrecte
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001450; --Error validar moviment sinistre
   END f_movsini;

   /*************************************************************************
      FUNCTION f_trasini
         Valida la tramitació del sinistre
         param in pctiptra  : Tipo tramitación
         param in pctcausin : Tipus dany
         param in pcinform  : Indicador tramitació informativa
         param in pttramita : Descripción tramtiación
         param in pmarca    : Marca vehículo
         param in pmodel    : Modelo vehículo
         param in psperson  : Codi persona
         param in ptnomvia  : Nom via
         param in pcsiglas  : Siglas
         param in pcpoblac  : Codi població
         param in pcprovin  : Codi provincia
         param in pcpais    : Codi pais
         param in ptdirec   : Descripció direcció
         param in pccompani : Código de la compañia contraria
         param in pcpolcia  : Numero de pólizza contraria
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 15260 - 07/06/2010 - AMC - Se añaden los campos pccompani y pcpolcia
   *************************************************************************/
   FUNCTION f_trasini(pctiptra  IN NUMBER,
                      pctcausin IN NUMBER,
                      pcinform  IN NUMBER,
                      pttramita IN VARCHAR2,
                      psperson  IN NUMBER,
                      pmarca    IN VARCHAR2,
                      pmodel    IN VARCHAR2,
                      ptnomvia  IN VARCHAR2,
                      pcsiglas  IN NUMBER,
                      pcpoblac  IN NUMBER,
                      pcprovin  IN NUMBER,
                      pcpais    IN NUMBER,
                      ptdirec   IN VARCHAR2,
                      pccompani IN NUMBER,
                      pcpolcia  IN VARCHAR2) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_trasini';
      vparam      VARCHAR2(2000) := 'parámetros - pctiptra: ' || pctiptra ||
                                    ' pctcausin: ' || pctcausin ||
                                    ' pcinform:' || pcinform ||
                                    ' pttramita: ' || pttramita ||
                                    ' psperson: ' || psperson ||
                                    ' pmarca: ' || pmarca || ' pmodel: ' ||
                                    pmodel || ' ptnomvia: ' || ptnomvia ||
                                    ' pcsiglas : ' || pcsiglas ||
                                    ' pcpoblac: ' || pcpoblac ||
                                    ' pcprovin: ' || pcprovin ||
                                    ' pcpais: ' || pcpais || ' ptdirec: ' ||
                                    ptdirec || ' pccompani:' || pccompani ||
                                    ' pcpolcia:' || pcpolcia;
      vpasexec    NUMBER(5) := 1;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pctiptra IS NULL
      THEN
         RETURN 9001890;
      END IF;

      IF pctcausin IS NULL
      THEN
         RETURN 9001384;
      END IF;

      IF pcinform IS NULL
      THEN
         RETURN 9001385;
      END IF;

      --IF pctiptra <> 0 THEN
      --   RETURN 9001386;
      --END IF;
      IF pctiptra IN (1, 2)
      THEN
         -- Vehícle assegurat/ Vehícle Contrari
         IF pmarca IS NULL
         THEN
            RETURN 9001385;
         END IF;

         IF pmodel IS NULL
         THEN
            RETURN 9001385;
         END IF;
      ELSIF pctiptra = 3
      THEN
         --Víctima
         IF psperson IS NULL
         THEN
            RETURN 9001387;
         END IF;
      ELSIF pctiptra = 5
      THEN
         --Direcció
         IF ptdirec IS NULL
         THEN
            IF pcsiglas IS NULL OR
               ptnomvia IS NULL OR
               pcpoblac IS NULL OR
               pcprovin IS NULL OR
               pcpais IS NULL
            THEN
               RETURN 9001389;
            END IF;
         END IF;
      ELSIF pctiptra IN (6, 7)
      THEN
         --Vehícle Assegurat / Vehícle Contrari
         IF psperson IS NULL
         THEN
            RETURN 9001387;
         END IF;
      END IF;

      -- Bug 15260 - 07/06/2010 - AMC
      IF (pccompani IS NULL AND pcpolcia IS NOT NULL) OR
         (pccompani IS NOT NULL AND pcpolcia IS NULL)
      THEN
         RETURN 9901279;
      END IF;

      -- Fi Bug 15260 - 07/06/2010 - AMC
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001449; --Error validar tramitació sinistre
   END f_trasini;

   /*************************************************************************
      FUNCTION f_movtrami
         Valida el moviment de tramitació
         param in pnsinies  : número de sinistre
         param in pntramit  : número de tramitació
         param in pcesttra  : estat tramitació
         param in ppagos    : Tamany de l'objecte de pagaments (>0 hi han pagaments)
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movtrami(pnsinies IN VARCHAR2,
                       pntramit IN NUMBER,
                       pcesttra IN NUMBER,
                       ppagos   IN NUMBER,
                       pcsubtra IN NUMBER DEFAULT NULL) RETURN NUMBER IS
      vobjectname  VARCHAR2(500) := 'pac_validaciones_sin.f_movtrami';
      vparam       VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies ||
                                    ' pntramit:' || pntramit ||
                                    ' pcesttra:' || pcesttra ||
                                    ' pcsubtra : ' || pcsubtra;
      vpasexec     NUMBER(5) := 1;
      vcesttra_ant NUMBER(2);
      vcsubtra_ant NUMBER;
      v_cempres    NUMBER;
      v_cnivper    NUMBER;
      v_dummy      NUMBER := 0;
      vnerror      NUMBER := 0;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL OR
         pntramit IS NULL
      THEN
         RETURN 9001392;
      END IF;

      IF pcesttra IS NULL OR
         pcesttra < 0
      THEN
         RETURN 9000927; --Campo Código Estado Tramitación obligatorio
      END IF;

      --Bug.: 19172 - ICV - 04/08/2011
      BEGIN
         SELECT cesttra,
                csubtra
           INTO vcesttra_ant,
                vcsubtra_ant
           FROM sin_tramita_movimiento
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND nmovtra IN (SELECT MAX(nmovtra)
                              FROM sin_tramita_movimiento
                             WHERE nsinies = pnsinies
                               AND ntramit = pntramit);
      EXCEPTION
         WHEN no_data_found THEN
            --és el primer moviment de tramitació
            vcesttra_ant := NULL;
            vcsubtra_ant := NULL;
      END;

      SELECT s.cempres
        INTO v_cempres
        FROM sin_siniestro ss,
             seguros       s
       WHERE ss.sseguro = s.sseguro
         AND ss.nsinies = pnsinies;

      BEGIN
         SELECT DISTINCT cnivper
           INTO v_cnivper
           FROM sin_codtramitador sc
          WHERE cusuari = f_user
            AND cempres = v_cempres
            AND cactivo = 1
            AND ctiptramit = 3; -- Bug 33298 - 04/11/2014 - JTT
      EXCEPTION
         WHEN no_data_found THEN
            v_cnivper := NULL;
         WHEN too_many_rows THEN
            v_cnivper := NULL;
      END;

      IF v_cnivper IS NULL
      THEN
         BEGIN
            SELECT MIN(cnivper)
              INTO v_cnivper
              FROM sin_codtramitador sc
             WHERE cusuari =
                   pac_parametros.f_parempresa_t(v_cempres, 'USER_BBDD')
               AND cempres = v_cempres
               AND cactivo = 1
               AND ctiptramit = 3; -- Bug 33298 - 04/11/2014 - JTT
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 9902263;
         END;
      END IF;

      SELECT COUNT('1')
        INTO v_dummy
        FROM sin_transiciones st
       WHERE st.cempres = v_cempres
         AND st.ctiptra = 2
         AND st.cnivper = v_cnivper
         AND (vcesttra_ant IS NULL OR st.cestant = vcesttra_ant)
         AND (st.csubant IS NULL OR st.csubant = vcsubtra_ant)
         AND (pcesttra IS NULL OR st.cestsig = pcesttra)
         AND (st.csubsig IS NULL OR st.csubsig = pcsubtra)
         AND (pcesttra IN (2, 3) AND NVL(ppagos, 0) = NVL(st.cotros, 0) OR
             pcesttra NOT IN (2, 3));

      IF v_dummy = 0
      THEN
         RETURN 9902264;
      END IF;

      IF pcesttra <> 0
      THEN
         vnerror := pac_siniestros.f_estado_tramitacion(pnsinies,
                                                        pntramit,
                                                        pcesttra);

         IF vnerror <> 0
         THEN
            RETURN vnerror;
         END IF;
      END IF;

      /*
      IF vcesttra_ant IS NULL THEN
         IF pcesttra <> 0 THEN
            RETURN 9001393;   --El moviment actual només pot tenir estat: 'OBERT'
         END IF;
      ELSIF vcesttra_ant = 0 THEN
         -- Bug 12668 - 01/03/2010 - AMC
         --IF pcesttra NOT IN(1, 2, 3) THEN
         --   RETURN 9001394;   --El moviment actual només pot tenir estat: 'FINALITZAT','ANUL·LAT','REBUTJAT'
         --ELSE
         IF pcesttra IN(2, 3) THEN
            --mirem que no hagin pagaments
            IF NVL(ppagos, 0) > 0 THEN
               RETURN 9001395;   --El moviment actual té pagaments pendents
            END IF;
         END IF;
      --Fi Bug 12668 - 01/03/2010 - AMC
      ELSIF vcesttra_ant = 1 THEN
         IF pcesttra <> 4 THEN
            RETURN 9001396;   --El moviment actual només pot tenir estat: 'REOBERT'
         END IF;
      ELSIF vcesttra_ant IN(2, 3) THEN
         RETURN 9001397;   --No es poden donar d'alta més moviments
      END IF;*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001443; --Error validar moviment tramitació
   END f_movtrami;

   /*************************************************************************
      FUNCTION f_loctrami
         Valida les dades de la direcció del sinistre
         param in ptnomvia   : Nom via
         param in pcsiglas   : Siglas
         param in pcpoblac   : Codi població
         param in pcprovin   : Codi provincia
         param in pcpais     : Codi pais
         param in ptdirec    : Descripció direcció
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_loctrami(ptnomvia IN VARCHAR2,
                       pcsiglas IN NUMBER,
                       pcpoblac IN NUMBER,
                       pcprovin IN NUMBER,
                       pcpais   IN NUMBER,
                       ptdirec  IN VARCHAR2) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_loctrami';
      vparam      VARCHAR2(500) := 'parámetros - ptnomvia:' || ptnomvia ||
                                   ' pcsiglas:' || pcsiglas || ' pcpoblac:' ||
                                   pcpoblac || 'pcprovin:' || pcprovin ||
                                   'pcpais:' || pcpais || 'ptdirecc:' ||
                                   ptdirec;
      vpasexec    NUMBER(5) := 1;
   BEGIN
      --Comprovació dels parámetres d'entrada
      IF ptdirec IS NULL
      THEN
         IF pcsiglas IS NULL OR
            ptnomvia IS NULL OR
            pcpoblac IS NULL OR
            pcprovin IS NULL OR
            pcpais IS NULL
         THEN
            RETURN 9001389; --Error validacions localització
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001442; --Error validar localització tramitació
   END f_loctrami;

   /*************************************************************************
      FUNCTION f_dantrami
         Valida les dades dels danys d'un sinistre
         param in pnsinies   : número de sinistre
         param in pntramit   : número de tramitació
         param in ptdano     : Descripció dany
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dantrami(pnsinies IN VARCHAR2,
                       pntramit IN NUMBER,
                       ptdano   IN VARCHAR2) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_dantrami';
      vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies ||
                                   ' pntramit:' || pntramit || ' ptdano:' ||
                                   ptdano;
      vpasexec    NUMBER(5) := 1;
      vexist      VARCHAR2(1) := 'S';
   BEGIN
      IF ptdano IS NULL
      THEN
         RETURN 9001411; --Descripció del Dany obligatoria
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001441; --Error validar dany
   END f_dantrami;

   /*************************************************************************
      FUNCTION f_dantrami
         Valida les dades dels danys d'un sinistre
         param in pnsinies   : número de sinistre
         param in pntramit   : número de tramitació
         param in pndetdano  : Tipus de dany (valor fixe: 0: Sin daños, 1: Sección Delantera, etc)
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dandettrami(pnsinies  IN VARCHAR2,
                          pntramit  IN NUMBER,
                          pndano    IN NUMBER,
                          pndetdano IN NUMBER) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_dandettrami';
      vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies ||
                                   ' pntramit:' || pntramit ||
                                   ' pndetdano:' || pndetdano;
      vpasexec    NUMBER(5) := 1;
      vexist      VARCHAR2(1) := 'N';
      vcobjase    seguros.cobjase%TYPE;
   BEGIN
      BEGIN
         SELECT sg.cobjase
           INTO vcobjase
           FROM seguros       sg,
                sin_siniestro si
          WHERE sg.sseguro = si.sseguro
            AND si.nsinies = pnsinies;
      EXCEPTION
         WHEN OTHERS THEN
            vcobjase := NULL;
      END;

      IF pndetdano <> 0 AND
         vcobjase = 5
      THEN
         BEGIN
            SELECT 'S'
              INTO vexist
              FROM sin_tramita_detdano
             WHERE nsinies = pnsinies
               AND ntramit = pntramit
               AND ndano = pndano
               AND ndetdano = 0;
         EXCEPTION
            WHEN no_data_found THEN
               vexist := 'N';
         END;
      END IF;

      IF vexist = 'S'
      THEN
         RETURN 9001412; --Tipus de danys incompatibles
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001441; --Error validar dany
   END f_dandettrami;

   /*************************************************************************
      FUNCTION f_restrami
         Valida les dades de les reserves d'una tramitació
         param in pnsinies  : Número de sinistre
         param in pntramit  : Número de tramitació
         param in pccausa   : Codi causa
         param in pctipres  : Tipus de reserva
         param in pcgarant  : Codi garantia
         param in pccalres  : Càlcul reserva
         param in pireserva : Import reserva
         param in picaprie  : Capital en risc
         param in pipenali  : Import penalització
         param in pdinici   : Data inici
         param in pdfi      : Data fi
         param in pcmonres  : Moneda de la reserva
         param in ptorigen  : Pantalla que llama al alta de reservas
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_restrami(pnsinies  IN VARCHAR2,
                       pntramit  IN NUMBER,
                       pccausa   IN NUMBER,
                       pctipres  IN NUMBER,
                       pcgarant  IN NUMBER,
                       pccalres  IN NUMBER,
                       pireserva IN NUMBER,
                       picaprie  IN NUMBER,
                       pipenali  IN NUMBER,
                       pdinici   IN DATE,
                       pdfi      IN DATE,
                       pcmonres  IN VARCHAR2,
                       ptorigen  IN VARCHAR2,
                       -- BUG 20014 - 24/01/2012 - JMP - LCOL_S001-SIN - Reservas y pagos en tramitaciones cerradas
                       presult OUT NUMBER,
                       pndias  IN NUMBER) -- 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
    RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_restrami';
      vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies ||
                                   ' pntramit:' || pntramit || ' pccausa:' ||
                                   pccausa || ' pctipres:' || pctipres ||
                                   ' pcgarant:' || pcgarant || ' pccalres:' ||
                                   pccalres || ' pireserva:' || pireserva ||
                                   ' picaprie:' || picaprie || ' pipenali:' ||
                                   pipenali || ' pdinici:' || pdinici ||
                                   ' pdfi:' || pdfi;
      vpasexec    NUMBER(5) := 1;
      vesvida     VARCHAR2(1) := 'N';
      --Indica si és un sinistre de vida
      -- BUG14281:DRA:26/04/2010:Inici
      v_sproduc NUMBER;
      v_cramo   NUMBER;
      v_cmodali NUMBER;
      v_ctipseg NUMBER;
      v_ccolect NUMBER;
      v_cactivi NUMBER;
      v_es_baja NUMBER;
      -- BUG14281:DRA:26/04/2010:Fi

      -- Bug 14816 - 02/06/2010 - AMC
      v_sseguro   NUMBER;
      v_error     NUMBER;
      v_capital   NUMBER;
      v_carencia  NUMBER;
      v_fefecto   DATE;
      v_fsinies   DATE;
      v_nmovi     NUMBER;
      v_cunitra   sin_movsiniestro.cunitra%TYPE;
      v_ctramitad sin_movsiniestro.ctramitad%TYPE;
      --Fi Bug 14816 - 02/06/2010 - AMC
      v_estrasp VARCHAR2(1) := 'N';
      --BUG15050:DRA:18/06/2010
      v_valresinfcap parproductos.cvalpar%TYPE;
      -- Bug 0020610 - 20/12/2011 - JMF
      -- Bug 0020610 - 16/01/2012 - JMF:
      v_gar_renta NUMBER;
      -- BUG 20014 - 19/01/2012 - JMP - No permitir crear nuevas reservas en siniestros o tramitaciones cerrados
      v_cestado sin_tramita_movimiento.cesttra%TYPE;
      -- FIN BUG 20014 - 19/01/2012 - JMP - No permitir crear nuevas reservas en siniestros o tramitaciones cerrados
      v_cmondef      eco_codmonedas.cmoneda%TYPE;
      v_cmonpro      productos.cdivisa%TYPE;
      v_cmonpro_t    monedas.cmonint%TYPE;
      v_cempres      NUMBER; -- 22108:ASN:29/05/2012
      v_ccausin      NUMBER; -- 22108:ASN:29/05/2012
      v_cmotsin      NUMBER; -- 22108:ASN:29/05/2012
      v_hay_tramites NUMBER; -- 22108:ASN:29/05/2012
      v_ntramte      NUMBER; -- 22108:ASN:29/05/2012
      v_iprovis      NUMBER; -- 22108:ASN:29/05/2012
      v_limite       NUMBER; -- 22108:ASN:29/05/2012
      vcpasmax       NUMBER;
      -- Bug 27739 - 25/07/2013 - RCL - No validación reserva respecto a capital garantía
      v_empresa_val_gar NUMBER;
      -- 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
      v_val_gar NUMBER;
      -- 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
      v_nriesgo NUMBER;
      -- 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
      v_terror VARCHAR2(1000);
      v_coste  NUMBER;
      --33701/ POSSIN - AJUSTES SEGUN FICHAS DE SINIESTROS
   BEGIN
      vpasexec := 1000;
      presult  := 0;

      IF pctipres = 1
      THEN
         --tipus de reserva "1.-Indemnizatoria"
         IF pcgarant IS NULL
         THEN
            RETURN 9001413; --Garantia obligatoria
         END IF;
      END IF;

      IF pccalres IS NULL
      THEN
         RETURN 9001414; --Càlcul de Reserva obligatori
      END IF;

      IF pireserva IS NULL AND
         pccalres = 0
      THEN
         RETURN 9001415; --Import Reserva obligatori
      END IF;

      BEGIN
         vpasexec := 1010;

         SELECT 'S'
           INTO vesvida
           FROM productos     pro,
                sin_siniestro sini,
                seguros       seg
          WHERE sini.nsinies = pnsinies
            AND seg.sseguro = sini.sseguro
            AND seg.sproduc = pro.sproduc
            AND pro.cagrpro IN (1, 2, 5, 10, 21);
         -- Bug 14816 - 02/06/2010 - AMC
         -- BUG 17660 - 16/02/2011 - JMP - Añadimos la agrupación 5 (Salud)
      EXCEPTION
         WHEN no_data_found THEN
            vesvida := 'N';
      END;

      -- BUG14281:DRA:26/04/2010:Inici
      BEGIN
         vpasexec := 1020;

         SELECT seg.sseguro,
                seg.cramo,
                seg.cmodali,
                seg.ctipseg,
                seg.ccolect,
                seg.cactivi,
                seg.sproduc,
                seg.fefecto,
                sini.fsinies,
                seg.cempres,
                sini.ccausin,
                sini.cmotsin,
                -- 22108:ASN:24/05/2012
                sini.nriesgo
         -- BUG 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
           INTO v_sseguro,
                v_cramo,
                v_cmodali,
                v_ctipseg,
                v_ccolect,
                v_cactivi,
                v_sproduc,
                v_fefecto,
                v_fsinies,
                v_cempres,
                v_ccausin,
                v_cmotsin,
                -- 22108:ASN:24/05/2012
                v_nriesgo
         -- BUG 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
           FROM sin_siniestro sini,
                seguros       seg
          WHERE sini.nsinies = pnsinies
            AND seg.sseguro = sini.sseguro;

         vpasexec  := 1030;
         v_es_baja := f_pargaranpro_v(v_cramo,
                                      v_cmodali,
                                      v_ctipseg,
                                      v_ccolect,
                                      v_cactivi,
                                      pcgarant,
                                      'BAJA');
         v_estrasp := 'N';
         -- Bug 0020610 - 20/12/2011 - JMF
         vpasexec       := 1040;
         v_valresinfcap := NVL(pac_parametros.f_parproducto_n(v_sproduc,
                                                              'VALRESINFCAP'),
                               0);
         -- Bug 0020610 - 16/01/2012 - JMF
         vpasexec    := 1050;
         v_gar_renta := NVL(f_pargaranpro_v(v_cramo,
                                            v_cmodali,
                                            v_ctipseg,
                                            v_ccolect,
                                            v_cactivi,
                                            pcgarant,
                                            'GARRENTA'),
                            0);
         --Mantis 37903/215023 - se adiciona validacion NVL - BLA - DD05/MM10/2015.
         -- BUG 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
         vpasexec          := 1060;
         v_empresa_val_gar := NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                'VAL_ALTA_SIN'),
                                  0);
         vpasexec          := 1070;
         v_val_gar         := NVL(f_pargaranpro_v(v_cramo,
                                                  v_cmodali,
                                                  v_ctipseg,
                                                  v_ccolect,
                                                  v_cactivi,
                                                  pcgarant,
                                                  'VAL_GAR_ALTA_SIN'),
                                  0);
         -- FIN BUG 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
      EXCEPTION
         WHEN no_data_found THEN
            vesvida           := 'N';
            v_es_baja         := 0;
            v_estrasp         := 'S';
            v_valresinfcap    := 0; -- Bug 0020610 - 20/12/2011 - JMF
            v_gar_renta       := 0; -- Bug 0020610 - 16/01/2012 - JMF
            v_empresa_val_gar := 0; -- Bug 24708/162026 - 03/01/2014 - NSS
            v_val_gar         := 0; -- Bug 24708/162026 - 03/01/2014 - NSS
      END;

      -- BUG 24708/162026 - 03/01/2014 - NSS - Validaciones garantia
      IF v_empresa_val_gar = 1 AND
         v_val_gar = 1 AND
         ptorigen IN ('axissin010')
      THEN
         v_error := pac_validaciones_sin.f_valida_garantia(v_sseguro,
                                                           v_nriesgo,
                                                           pcgarant,
                                                           pndias,
                                                           v_fsinies,
                                                           pdinici,
                                                           pdfi,
                                                           ptorigen,
                                                           v_terror);

         IF v_error = 9906391
         THEN
            v_error := 9906413;
         ELSIF v_error = 9906392
         THEN
            v_error := 9906414;
         END IF;

         IF v_error <> 0
         THEN
            RETURN v_error;
         END IF;
      END IF;

      -- FIN BUG 24708/162026 - 03/01/2014 - NSS - Validaciones garantia

      -- BUG 18423 - 20/01/2012 - JMP - Multimoneda
      vpasexec    := 1060;
      v_cmondef   := NVL(pac_eco_monedas.f_obtener_moneda_defecto, 'EUR');
      v_cmonpro   := pac_monedas.f_moneda_producto(v_sproduc);
      v_cmonpro_t := NVL(pac_monedas.f_cmoneda_t(v_cmonpro), v_cmondef);

      IF pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA') <> 1
      THEN
         IF pctipres = 1
         THEN
            IF pcmonres <> v_cmonpro_t
            THEN
               RETURN 9903148;
               -- Para este tipo de reserva la moneda debe coincidir con la del producto
            END IF;
         END IF;
      END IF;

      -- FIN BUG 18423 - 20/01/2012 - JMP - Multimoneda
      -- BUG 20014 - 19/01/2012 - JMP - No permitir crear nuevas reservas en siniestros o tramitaciones cerrados
      --                                si la pantalla que llama al alta de reservas es la de gestión de siniestros
      vpasexec := 1070;

      IF ptorigen = 'axissin010'
      THEN
         vpasexec  := 1080;
         v_cestado := pac_siniestros.f_get_estado_siniestro(pnsinies);

         IF v_cestado IN (1, 2, 3)
         THEN
            RETURN 9903147;
            -- No se permite generar nuevas reservas para un siniestro cerrado
         ELSE
            vpasexec  := 1090;
            v_cestado := pac_siniestros.f_get_cesttra(pnsinies, pntramit);

            IF v_cestado IN (1, 2, 3)
            THEN
               RETURN 9903146;
               -- No se permite generar nuevas reservas para una tramitación cerrada
            END IF;
         END IF;
      END IF;

      vpasexec := 1100;

      -- FIN BUG 20014 - 19/01/2012 - JMP - No permitir crear nuevas reservas en siniestros o tramitaciones cerrados
      IF v_estrasp = 'N'
      THEN
         -- BUG15050:DRA:18/06/2010
         IF vesvida = 'S' AND
            v_es_baja = 0
         THEN
            --És un producte de VIDA
            IF picaprie IS NULL
            THEN
               RETURN 9001416; --Capital en Risc obligatori
            END IF;

            IF pipenali IS NULL
            THEN
               RETURN 9001417; --Import Penalització obligatori
            END IF;
         ELSIF v_es_baja = 1 AND
               pctipres = 1
         THEN
            -- Bug 30843 - 01/04/2014 - JTT:  Unicamente validamos las fechas para las reservas indemnizatorias
            --es sinistre de baixa
            IF pdfi IS NULL
            THEN
               RETURN 9001419; --Data Fi obligatoria
            ELSIF TRUNC(pdfi) < TRUNC(pdinici)
            THEN
               RETURN 9001418;
               --La Data Fi no pot ser inferior a la Data Inici
            END IF;
         END IF;

         -- BUG14281:DRA:26/04/2010:Fi

         -- Bug 14816 - 02/06/2010 - AMC
         -- Bug 0020610 - 20/12/2011 - JMF: Parametro para validar si reserva inferior a capital
         -- Bug 0020610 - 13/01/2012 - JMF: Excluir siniestros de muerte que llevan Ahorro y Valor de rescate
         -- Bug 0020610 - 13/01/2012 - JMF: Excluir validaciones las que tienen renta.
         vpasexec := 1110;

         -- Bug 26200 - 04-III-2013 - dlF - saltarnos la validación de que el importe de la reserva
         --                                sea inferior o igual al capital de la garantía.
         -- Inici Bug 027739 - 25/07/2013 - RCL - No validación reserva respecto a capital garantía
         IF pcgarant IS NOT NULL
         THEN
            SELECT NVL(cpasmax, 0)
              INTO vcpasmax
              FROM garanpro
             WHERE sproduc = v_sproduc
               AND cgarant = pcgarant
               AND cactivi = v_cactivi;
         ELSE
            vcpasmax := 1;
         END IF;

         IF f_parproductos_v(v_sproduc, 'RESERVA_VAL_CAPITAL') != 1
         THEN
            IF vcpasmax = 1
            THEN
               --Si no se ha de validar capital para esta garantía
               NULL;
            ELSIF (pctipres = 1 AND vesvida = 'N' AND NVL(v_es_baja, 0) = 0) OR
                  (pctipres = 1 AND vesvida = 'S' AND NVL(v_es_baja, 0) = 0 AND
                  v_valresinfcap = 1 AND v_gar_renta = 0 AND
                  NVL(f_pargaranpro_v(v_cramo,
                                       v_cmodali,
                                       v_ctipseg,
                                       v_ccolect,
                                       v_cactivi,
                                       pcgarant,
                                       'GAR_CONTRA_CTASEGURO'),
                       1) = 0)
            THEN
               vpasexec := 1120;
               v_error  := pac_siniestros.f_get_capitalgar(pcgarant,
                                                           v_sseguro,
                                                           pnsinies,
                                                           v_capital,
                                                           pcmonres);

               -- BUG 18423 - 16/01/2012 - JMP - Multimoneda

               --INICIO - DCT - 23/12/2014 - 0028311: POSSIN - AJUSTES SEGUN FICHAS DE SINIESTROS
               SELECT NVL(SUM(ipago), 0) + NVL(SUM(itotimp), 0) -
                      (NVL(SUM(iingreso), 0) + NVL(SUM(irecobro), 0) +
                       NVL(SUM(itotret), 0))
                 INTO v_coste
                 FROM sin_tramita_reserva str
                WHERE str.nsinies = pnsinies
                  AND str.ntramit = pntramit
                  AND str.ctipres = 1
                  AND NVL(str.cgarant, -1) = NVL(pcgarant, -1)
                  AND (str.fresini = pdinici OR pdinici IS NULL)
                  AND str.nmovres =
                      (SELECT MAX(nmovres)
                         FROM sin_tramita_reserva
                        WHERE nsinies = str.nsinies
                          AND ntramit = str.ntramit
                          AND ctipres = str.ctipres
                          AND NVL(cgarant, -1) = NVL(pcgarant, -1)
                          AND (fresini = str.fresini OR fresini IS NULL)
                          AND fmovres <= f_sysdate);

               IF NVL(v_capital, 0) > 0 AND
                  NVL(v_capital, 0) < NVL(v_coste, 0) + NVL(pireserva, 0)
               THEN
                  RETURN 9901224;
               END IF;
               --IF NVL(v_capital, 0) > 0
               --   AND NVL(v_capital, 0) < NVL(pireserva, 0) THEN
               --   RETURN 9901224;
               --END IF;
               --FIN - DCT - 23/12/2014 - 0028311: POSSIN - AJUSTES SEGUN FICHAS DE SINIESTROS
            END IF;
         END IF;
         -- Fi Bug 027739 - 25/07/2013 - RCL - No validación reserva respecto a capital garantía
         -- Fi bug 26200 - 04-III-2013 - dlF
      END IF;

      -- Fi bug 14816 - 02/06/2010 - AMC
      IF pcgarant IS NOT NULL AND
         pireserva IS NOT NULL
      THEN
         vpasexec := 1170;
         v_error  := pac_siniestros.f_val_reserva_capitales(pnsinies,
                                                            pcgarant,
                                                            pireserva);

         IF v_error <> 0
         THEN
            RETURN v_error;
         END IF;
      END IF;

      -- 24708/0157216 ASN:29/10/2013 INI (Modificacion fecha inicio de la baja)
      IF ptorigen IN ('axissin010', 'axissin027')
      THEN
         -- 0024708/0157228 (POSPG500)- Parametrizacion - Sinestros
         -- solo validamos en alta de reserva y reapertura de siniestro
         -- Bug 30843 - 01/04/2014 - JTT:  Unicamente validamos las fechas para las reservas indemnizatorias
         IF v_es_baja = 1 AND
            pctipres = 1
         THEN
            IF pdinici IS NULL
            THEN
               RETURN 9901215; -- Fecha inicio y fin obligatoria
            END IF;

            IF pdinici > pdfi
            THEN
               RETURN 110361;
               -- fecha de inicio no puede ser posterior a la fecha inicial
            END IF;

            IF TRUNC(pdinici) < TRUNC(v_fsinies)
            THEN
               RETURN 9906220;
               -- Fecha de inicio no puede ser anterior a la fecha de ocurrencia
            END IF;

            -- Bug 35654 - 23/04/2015 - JTT: No tenemos en cuenta la reserva correpondiente al intervalo que estamos tratando
            -- Bug 35654 - 13/05/2015 - JTT: No tenemos en cuenta los intervalos con reserva 0
            FOR i IN (SELECT r.*
                        FROM sin_tramita_reserva r
                       WHERE r.nsinies = pnsinies
                         AND r.ntramit = pntramit
                         AND r.ctipres = pctipres
                         AND r.cgarant = pcgarant
                         AND r.ireserva + NVL(r.ipago, 0) > 0
                            -- Excluimos los intervalos con coste 0
                         AND r.nmovres =
                             (SELECT MAX(nmovres)
                                FROM sin_tramita_reserva
                               WHERE nsinies = r.nsinies
                                 AND idres = r.idres)
                         AND idres NOT IN
                             (SELECT DISTINCT (idres)
                              -- Excluimos la reserva que estamos tratando
                                FROM sin_tramita_reserva
                               WHERE nsinies = r.nsinies
                                 AND ntramit = r.ntramit
                                 AND ctipres = r.ctipres
                                 AND cgarant = r.cgarant
                                 AND fresini = pdinici
                                 AND fresfin = pdfi))
            LOOP
               -- Bug 35654 - 30/04/2015 - JTT: Se permiten que el primer dia del siguient periodo coincida con el ultimo dia del periodo anterior.
               IF pdinici >= i.fresini AND
                  pdinici < i.fresfin
               THEN
                  RETURN 9906221;
                  -- El intervalo se solapa con otro ya existente
               END IF;

               IF pdfi >= i.fresini AND
                  pdfi <= i.fresfin
               THEN
                  RETURN 9906221;
                  -- El intervalo se solapa con otro ya existente
               END IF;
            END LOOP;
         END IF;
         -- 24708/0157216 ASN:29/10/2013 FIN
      END IF;

      -- 22108:ASN:24/05/2012 ini
      IF pireserva IS NOT NULL
      THEN
         vpasexec := 1180;

         SELECT pac_sin_tramite.ff_hay_tramites(pnsinies)
           INTO v_hay_tramites
           FROM dual;

         vpasexec := 1190;

         SELECT ntramte
           INTO v_ntramte
           FROM sin_tramitacion
          WHERE nsinies = pnsinies
            AND ntramit = pntramit;

         v_iprovis := 0;
         vpasexec  := 1200;

         FOR tr IN (SELECT ntramit
                      FROM sin_tramitacion
                     WHERE ntramte = v_ntramte
                       AND v_hay_tramites = 1
                    -- todas las tramitaciones de un tramite
                    UNION
                    SELECT pntramit
                      FROM dual
                     WHERE v_hay_tramites = 0) -- solo una tramitacion en concreto
         LOOP
            vpasexec := 1210;

            SELECT v_iprovis +
                   SUM(NVL(r1.ireserva_moncia, NVL(r1.ireserva, 0)))
              INTO v_iprovis
              FROM sin_tramita_reserva r1
             WHERE r1.nsinies = pnsinies
               AND r1.ntramit = tr.ntramit
               AND r1.ctipres = 1 -- Indemnizatoria
               AND (r1.cgarant, NVL(r1.fresini, f_sysdate), r1.nmovres) IN
                   (SELECT r2.cgarant,
                           MAX(NVL(r1.fresini, f_sysdate)),
                           MAX(r2.nmovres)
                      FROM sin_tramita_reserva r2
                     WHERE r2.nsinies = r1.nsinies
                       AND r2.ntramit = r1.ntramit
                       AND r2.ctipres = r1.ctipres
                     GROUP BY cgarant)
               AND NOT (r1.ntramit = pntramit AND
                    NVL(r1.cgarant, -1) = NVL(pcgarant, -1)); -- no leemos la que vamos a modificar (si existe)

            vpasexec := 1220;

            SELECT NVL(v_iprovis, 0) +
                   SUM(NVL(r1.ipago_moncia, NVL(r1.ipago, 0))) -
                   SUM(NVL(r1.irecobro_moncia, NVL(r1.irecobro, 0)))
              INTO v_iprovis
              FROM sin_tramita_reserva r1
             WHERE r1.nsinies = pnsinies
               AND r1.ntramit = tr.ntramit
               AND r1.ctipres = 1 -- Indemnizatoria
               AND (r1.cgarant, NVL(r1.fresini, f_sysdate), r1.nmovres) IN
                   (SELECT r2.cgarant,
                           MAX(NVL(r2.fresini, f_sysdate)),
                           MAX(r2.nmovres)
                      FROM sin_tramita_reserva r2
                     WHERE r2.nsinies = r1.nsinies
                       AND r2.ntramit = r1.ntramit
                       AND r2.ctipres = r1.ctipres
                     GROUP BY cgarant);
         END LOOP;

         -- Bug 0023741 - 20/09/2012 - JMF
         v_iprovis := NVL(v_iprovis, 0) + NVL(pireserva, 0);
         vpasexec  := 1230;

         SELECT tm.ctramitad
           INTO v_ctramitad
           FROM sin_tramita_movimiento tm
          WHERE tm.nsinies = pnsinies
            AND tm.ntramit = pntramit
            AND tm.nmovtra = (SELECT MAX(tm2.nmovtra)
                                FROM sin_tramita_movimiento tm2
                               WHERE tm2.nsinies = tm.nsinies
                                 AND tm2.ntramit = tm.ntramit);

         vpasexec := 1240;
         v_error  := pac_siniestros.f_get_limite_tramitador(v_ctramitad,
                                                            v_cempres,
                                                            v_cramo,
                                                            v_ccausin,
                                                            v_cmotsin,
                                                            v_limite);

         IF v_error <> 0
         THEN
            RETURN v_error;
         END IF;

         IF v_ctramitad <> 'T000'
         THEN
            -- 23741:ASN:11/10/2012
            IF v_iprovis > v_limite
            THEN
               RETURN 9903735;
               -- El coste siniestral supera el limite del tramitador
            END IF;
         END IF;
      END IF;

      -- 22108:ASN:24/05/2012 fin
      vpasexec := 1250;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001440; --Error validar reserva
   END f_restrami;

   /*************************************************************************
      FUNCTION f_dest
         Valida les dades del destinatari
         param in pnsinies  : Número de sinistre
         param in pntramit  : Número de tramitació
         param in pccausa   : Codi causa
         param in pctipdes  : Tipus destinatari
         param in pcactpro  : Activitat professional
         param in psperson  : Codi persona
         param in ppasigna  : Percentatge assignació
         param in pcpaisre  : Codi país resident
         param in pcbancar  : Codi Bancari
         -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
         param IN  pctipcap : Tipo prestacion
         param IN  pcrelase : Relación con asegurado.
      -- Fi BUG 0015669 - 08/2010 - JRH
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_dest(pnsinies IN VARCHAR2,
                   pntramit IN NUMBER,
                   pccausa  IN NUMBER,
                   pctipdes IN NUMBER,
                   pcactpro IN NUMBER,
                   psperson IN NUMBER,
                   ppasigna IN NUMBER,
                   pcpaisre IN NUMBER,
                   pcbancar IN VARCHAR2,
                   -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
                   pctipcap IN NUMBER DEFAULT NULL,
                   pcrelase IN NUMBER DEFAULT NULL
                   -- Fi BUG 0015669 - 08/2010 - JRH
                   ) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_dest';
      vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies ||
                                   ' pntramit:' || pntramit || ' pccausa:' ||
                                   pccausa || ' pctipdes:' || pctipdes ||
                                   ' pcactpro:' || pcactpro || ' psperson:' ||
                                   psperson || ' ppasigna:' || ppasigna ||
                                   ' pcpaisre:' || pcpaisre || pctipcap ||
                                   ' crelase:' || pcrelase || ' pcbancar:' ||
                                   pcbancar;
      vpasexec    NUMBER(5) := 1;
      vesvida     VARCHAR2(1) := 'N'; --Indica si és un sinistre de vida
      -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
      vnum NUMBER;
      -- Fi BUG 0015669 - 08/2010 - JRH
   BEGIN
      IF pctipdes IS NULL
      THEN
         RETURN 9001420; --Tipus Destinatari obligatori'
      END IF;

      IF psperson IS NULL
      THEN
         RETURN 9000941; --Camp Destinatari obligatori
      END IF;

      IF pctipdes IN (2, 8, 9)
      THEN
         IF pcactpro IS NULL
         THEN
            RETURN 9001424; --Activitat Professional obligatoria
         END IF;
      END IF;

      BEGIN
         SELECT 'S'
           INTO vesvida
           FROM productos     pro,
                sin_siniestro sin,
                seguros       seg
          WHERE sin.nsinies = pnsinies
            AND seg.sseguro = sin.sseguro
            AND seg.sproduc = pro.sproduc
            AND pro.cagrpro = 1;
      EXCEPTION
         WHEN no_data_found THEN
            vesvida := 'N';
      END;

      IF vesvida = 'S'
      THEN
         --És un producte de VIDA
         IF ppasigna < 0 OR
            ppasigna > 100
         THEN
            RETURN 9001421;
            --El percentatge d''assignació ha d''estar entre 0 i 100
         END IF;

         IF pcpaisre IS NULL
         THEN
            RETURN 9001422; --País Resident obligatori
         END IF;
         --         IF pcbancar IS NULL THEN
         --            RETURN 9001423;   --Compte Bancari obligatori
         --         END IF;
      END IF;

      -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
      IF pctipcap IS NOT NULL
      THEN
         SELECT COUNT(*)
           INTO vnum
           FROM detvalores
          WHERE cvalor = 205
            AND catribu = NVL(pctipcap, 1);

         IF vnum = 0
         THEN
            RETURN 9901381;
         END IF;
      END IF;

      IF pcrelase IS NOT NULL
      THEN
         SELECT COUNT(*)
           INTO vnum
           FROM detvalores
          WHERE cvalor = 1018
            AND catribu = NVL(pcrelase, 1);

         IF vnum = 0
         THEN
            RETURN 9901382;
         END IF;
      END IF;

      IF pctipdes = 1
      THEN
         IF pcrelase IS NOT NULL
         THEN
            RETURN 9901382;
         END IF;
      END IF;

      IF NVL(pctipcap, 0) IN (0, 2, 4)
      THEN
         --JRH Si no es renta financiera no puede existir prestaren
         SELECT COUNT(*)
           INTO vnum
           FROM prestaren
          WHERE nsinies = pnsinies
            AND ntramit = ntramit
            AND sperson = psperson
            AND ctipdes = pctipdes;

         IF vnum > 0
         THEN
            RETURN 9901383;
         END IF;
      END IF;

      IF NVL(pctipcap, 0) = 1
      THEN
         --JRH Si sólo hay rentas no pueden haber pagos
         SELECT COUNT(*)
           INTO vnum
           FROM sin_tramita_pago a
          WHERE nsinies = pnsinies
            AND ntramit = ntramit
            AND sperson = psperson
            AND ctipdes = pctipdes
               -- Bug 0018812 - 21/06/2011 - JMF : rentas financieras con pagos no anualados
            AND EXISTS (SELECT 1
                   FROM sin_tramita_movpago b
                  WHERE b.sidepag = a.sidepag
                    AND b.nmovpag =
                        (SELECT MAX(b2.nmovpag)
                           FROM sin_tramita_movpago b2
                          WHERE b2.sidepag = b.sidepag)
                    AND b.cestpag <> 8);

         -- Bug 0021150 - 23/07/2012 - JMF
         IF vnum > 0
         THEN
            RETURN 9901545;
         END IF;
      END IF;

      IF NVL(pctipcap, 0) = 2
      THEN
         --JRH Si sólo hay rentas actuariales  no pueden haber pagos diferentes de tipo cconpag=4
         SELECT COUNT(*)
           INTO vnum
           FROM sin_tramita_pago a
          WHERE nsinies = pnsinies
            AND ntramit = ntramit
            AND sperson = psperson
            AND ctipdes = pctipdes
               -- Bug 0018812 - 21/06/2011 - JMF : rentas actuariales con pagos no anualados
            AND a.cconpag <> 4 -- Pago renta nuevo
            AND EXISTS (SELECT 1
                   FROM sin_tramita_movpago b
                  WHERE b.sidepag = a.sidepag
                    AND b.nmovpag =
                        (SELECT MAX(b2.nmovpag)
                           FROM sin_tramita_movpago b2
                          WHERE b2.sidepag = b.sidepag)
                    AND b.cestpag <> 8);

         -- Bug 0021150 - 23/07/2012 - JMF
         IF vnum > 0
         THEN
            RETURN 9901545;
         END IF;
      END IF;

      --JRH IMP Select sobre prestaren para ver si pctipcap puede ser 1

      -- Fi BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)

      -- Bug 0018812 - 21/06/2011 - JMF
      IF NVL(pctipcap, 0) NOT IN (2, 4)
      THEN
         SELECT COUNT(*)
           INTO vnum
           FROM sin_tramita_pago a
          WHERE a.nsinies = pnsinies
            AND a.ntramit = ntramit
            AND a.sperson = psperson
            AND a.ctipdes = pctipdes
            AND a.cconpag = 4 -- Pago renta nuevo
            AND EXISTS (SELECT 1
                   FROM sin_tramita_movpago b
                  WHERE b.sidepag = a.sidepag
                    AND b.nmovpag =
                        (SELECT MAX(b2.nmovpag)
                           FROM sin_tramita_movpago b2
                          WHERE b2.sidepag = b.sidepag)
                    AND b.cestval <> 8);

         IF vnum > 0
         THEN
            RETURN 9902142;
         END IF;
      END IF;

      -- Bug 0018812 - 21/06/2011 - JMF
      -- Ini bug 35101
      /* Bug 35608-206881 05/06/2015 KJSC sólo se debe hacer si el pctipdes:
      1 - Asegurado póliza
      7 - Tomador
      10 - Persona Asegurada
      56 - Asegurado Innominado*/
      IF pctipdes IN (1, 7, 10, 56)
      THEN
         vnum := pac_propio.f_valida_fiscalidad(psperson, pnsinies);
      END IF;

      IF vnum != 0
      THEN
         RETURN vnum;
      END IF;

      -- Fin bug 35101
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001439; --Error validar destinatari
   END f_dest;

   /*************************************************************************
      FUNCTION f_cabecerapago
         Valida les dades de la capçalera del pagament
         param in pnsinies  : Número de sinistre
         param in pntramit  : Número de tramitació
         param in pctippag  : Codi tipus pagament
         param in pctipdes  : Tipus destinatari
         param in pcconpag  : Concepte pagament
         param in pccauind  : Causa indemnització
         param in pcforpag  : Codi forma pagament
         param in pcbancar  : Codi Bancari
         param in pforden   : Data ordre
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
    -- BUG 13019 08/02/2010 ASN Incluir acceso al parametro de empresa 'SIN_FECHA_PAGO'
   *************************************************************************/
   FUNCTION f_cabecerapago(pnsinies        IN VARCHAR2,
                           pntramit        IN NUMBER,
                           pctippag        IN NUMBER,
                           pctipdes        IN NUMBER,
                           pcconpag        IN NUMBER,
                           pccauind        IN NUMBER,
                           pcforpag        IN NUMBER,
                           pcbancar        IN VARCHAR2,
                           pforden         IN DATE,
                           psidepag        IN NUMBER DEFAULT NULL,
                           pnombreoutfacta OUT VARCHAR2) --Bug.: 16280
    RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_cabecerapago';
      vparam      VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies ||
                                   ' pntramit:' || pntramit || ' pctippag:' ||
                                   pctippag || ' pctipdes:' || pctipdes ||
                                   ' pcconpag:' || pcconpag || ' pccauind:' ||
                                   pccauind || ' pcforpag:' || pcforpag ||
                                   ' pcbancar:' || pcbancar || ' psidepag:' ||
                                   psidepag;
      vpasexec    NUMBER(5) := 1;
      vesvida     VARCHAR2(1) := 'N';
      --Indica si és un sinistre de vida
      v_impreserva     NUMBER; -- BUG15171:DRA:28/06/2010
      sw_doc_pendiente NUMBER(1); -- BUG 21307/107043 - 14/02/2012 - JMP
      v_fnotifi        DATE; -- BUG 25537- 13/08/2013 - ASN
      v_error          NUMBER;
      v_cagrpro        seguros.cagrpro%TYPE;
      v_ctipper        per_personas.ctipper%TYPE;
      v_fatca_fisica   per_parpersonas.nvalpar%TYPE;
      v_fatca_juridica per_parpersonas.nvalpar%TYPE;
      v_cempres        seguros.cempres%TYPE;
      vresultado       NUMBER;
      v_perfacta       NUMBER := 0;
   BEGIN
      IF pctippag IS NULL
      THEN
         RETURN 9000943; --Camp Codi Tipus Pagament obligatori
      END IF;

      IF pctipdes IS NULL
      THEN
         RETURN 9001426; --Codi Destinatari obligatori
      END IF;

      IF pcconpag IS NULL
      THEN
         RETURN 9001427; --Concepte Pagament obligatori
      END IF;

      IF pccauind IS NULL
      THEN
         RETURN 9000945; --Camp Codi Causa Indemnització obligatori
      END IF;

      IF pcforpag IS NULL
      THEN
         RETURN 9000946; --Camp Codi Forma Pagament obligatori
      END IF;

      /* bug  30558#c169162 , jds, 19-03-2014
      IF pcforpag = 1   --forma pagament : transferència
         AND pcbancar IS NULL THEN
         RETURN 9001428;   --Codi Bancari obligatori
      END IF;*/
      IF pforden IS NULL
      THEN
         RETURN 9001431; --Data Ordre obligatoria
      ELSIF TRUNC(pforden) < TRUNC(f_sysdate) AND
            NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,

                                              -- BUG 13019 08/02/2010 ASN
                                              'SIN_FECHA_PAGO'),
                1) = 1
      THEN
         RETURN 9001430;
         --Data d''Ordre de Pagament no pot ser inferior a la data actual
         -- 25537:ASN:13/08/2013 ini
      ELSE
         SELECT fnotifi
           INTO v_fnotifi
           FROM sin_siniestro
          WHERE nsinies = pnsinies;

         IF TRUNC(pforden) < TRUNC(v_fnotifi)
         THEN
            RETURN 9905836;
            -- La fecha de pago no puede ser anterior a la fecha de declaracion del siniestro
         END IF;
         -- 25537:ASN:13/08/2013 fin
      END IF;

      -- Bug 34622/200538 - 13/03/2015 - JTT - Comprobación de la fecha de formalización
      v_error := pac_validaciones_sin.f_validar_fecha_formalizacion(pnsinies);

      IF v_error > 0
      THEN
         RETURN v_error;
      END IF;

      -- BUG 21307/107043 - 14/02/2012 - JMP - Comprobación de si hay documentación obligatoria pendiente de adjuntar
      SELECT DECODE(COUNT(*), 0, 0, 1)
        INTO sw_doc_pendiente
        FROM sin_tramita_documento
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND cobliga = 1
         AND iddoc IS NULL;

      IF sw_doc_pendiente = 1
      THEN
         RETURN 9903268;
         -- Hay documentación obligatoria pendiente de adjuntar
      END IF;

      -- FIN BUG 21307/107043 - 14/02/2012 - JMP - Comprobación de si hay documentación obligatoria pendiente de adjuntar
      --Bug.: 16280 - ICV - Solamente en el alta del pago se validan las reservas
      IF psidepag IS NULL AND
         pctippag = 2
      THEN
         -- Bug 17781 - 28/02/2011 - AMC
         IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                              'SINIS_CORR'),
                0) = 0
         THEN
            -- BUG15171:DRA:28/06/2010:Inici
            SELECT SUM(ireserva)
              INTO v_impreserva
              FROM (SELECT tr.ctipres,
                           tr.ctipgas,
                           tr.nmovres,
                           tr.cgarant,
                           SUM(tr.ireserva) ireserva
                      FROM sin_tramita_reserva tr
                     WHERE tr.nsinies = pnsinies
                       AND tr.ntramit = pntramit
                     GROUP BY tr.ctipres,
                              tr.ctipgas,
                              tr.nmovres,
                              tr.cgarant,
                              tr.cmonres,
                              tr.fresini,
                              tr.fresfin -- 31294/175939:NSS:27/05/2014
                    HAVING tr.nmovres = (SELECT MAX(tr1.nmovres)
                                          FROM sin_tramita_reserva tr1
                                         WHERE tr1.nsinies = pnsinies
                                           AND tr1.ntramit = pntramit
                                           AND tr1.ctipres = tr.ctipres
                                           AND NVL(tr1.ctipgas, '-1') =
                                               NVL(tr.ctipgas, '-1')
                                              -- 27055:ASN:29/05/2013
                                           AND NVL(tr1.cgarant, '-1') =
                                               NVL(tr.cgarant, '-1')
                                           AND tr1.cmonres = tr.cmonres
                                           AND NVL(tr1.fresini,
                                                   TO_DATE('01/01/1900',
                                                           'dd/mm/yyyy')) =
                                               NVL(tr.fresini,
                                                   TO_DATE('01/01/1900',
                                                           'dd/mm/yyyy')) -- 31294/175939:NSS:27/05/2014
                                           AND NVL(tr1.fresfin,
                                                   TO_DATE('01/01/1900',
                                                           'dd/mm/yyyy')) =
                                               NVL(tr.fresfin,
                                                   TO_DATE('01/01/1900',
                                                           'dd/mm/yyyy')) -- 31294/175939:NSS:27/05/2014
                                        ));

            -- BUG 18423 - 20/01/2012 - JMP - Multimoneda
            IF NVL(v_impreserva, 0) = 0
            THEN
               RETURN 9901260;
               -- No existeixen reserves amb import de pagament pendent
            END IF;
         END IF;
      END IF;

      -- BUG15171:DRA:28/06/2010:Fi
      -- Fi bug.: 16280
      -- Bug 34987/202058 Validación pago beneficiarios FATCA
      BEGIN
         SELECT ss.cagrpro,
                ss.cempres
           INTO v_cagrpro,
                v_cempres
           FROM sin_siniestro s,
                seguros       ss
          WHERE s.nsinies = pnsinies
            AND s.sseguro = ss.sseguro;
      EXCEPTION
         WHEN no_data_found THEN
            v_cagrpro := NULL;
      END;

      IF pac_parametros.f_parempresa_n(v_cempres, 'SIN_VALBENEFATCA') = 1
      THEN
         --IF v_cagrpro IN(2, 21) THEN
         FOR regs IN (SELECT sperson
                        FROM sin_tramita_destinatario
                       WHERE nsinies = pnsinies)
         LOOP
            SELECT ctipper
              INTO v_ctipper
              FROM per_personas
             WHERE sperson = regs.sperson;

            vresultado := pac_seguros.f_fatca_indicios(NULL,
                                                       NULL,
                                                       NULL,
                                                       'SEG',
                                                       regs.sperson);

            IF vresultado = 1
            THEN

               v_perfacta := 1;

               pnombreoutfacta := pnombreoutfacta || ',' ||
                                  f_nombre(regs.sperson, 3);

            END IF;

         END LOOP;

         IF v_perfacta <> 0
         THEN

            pnombreoutfacta := ' ( ' ||
                               SUBSTR(pnombreoutfacta,
                                      2,
                                      length(pnombreoutfacta)) || ' )';
            RETURN 9907787;

         END IF;

         --END IF;
      END IF;

      -- Fin bug 34987/202058
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001438; --Error validar la capçalera d''un pagament
   END f_cabecerapago;

   /*************************************************************************
      FUNCTION f_movpago
         Valida els moviments d'un pagament
         param in psidepag  : Codi seqüéncia pagament
         param in pcestpag  : Codi estat pagament
         param in pcestval  : Codi estat validació
         param in pcsubpag  : Código subestado del pago
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_movpago(psidepag IN NUMBER,
                      pcestpag IN NUMBER,
                      pcestval IN NUMBER,
                      pcsubpag IN NUMBER) -- Bug:19601 - 29/09/2011 - JMC
    RETURN NUMBER IS
      vobjectname  VARCHAR2(500) := 'pac_validaciones_sin.f_movpago';
      vparam       VARCHAR2(500) := 'parámetros - psidepag:' || psidepag ||
                                    ' pcestpag:' || pcestpag ||
                                    ' pcestval:' || pcestval ||
                                    ' pcsubpag:' || pcsubpag;
      vpasexec     NUMBER(5) := 1;
      vcestpag_ant NUMBER(1);
   BEGIN
      IF pcestval IS NULL
      THEN
         RETURN 9001453; --Estat Validació Pagament obligatori
      END IF;

      IF pcestpag IS NULL
      THEN
         RETURN 9001454; --Estat Pagament obligatori
      END IF;

      -- bug 14241 - JGM - 03/06/2010 -- Validación del importe
      DECLARE
         v_usuario VARCHAR2(50);
         v_importe NUMBER;
         v_limite  NUMBER;
         v_cramo   codiram.cramo%TYPE; -- bug 19601 - JMC - 05/10/2011
         v_sproduc NUMBER(6);
         v_moneda  VARCHAR2(3);
         v_ctiplim NUMBER(1);
         v_cempres empresas.cempres%TYPE;
         vnumemit  NUMBER;
         vcestpag  NUMBER;
         vcestval  NUMBER;
         -- Bug 0018812 - 21/06/2011 - JMF
         v_cconpag sin_tramita_pago.cconpag%TYPE;
         --Bug.: 19172
         v_cestant NUMBER;
         v_csubant NUMBER;
         v_cnivper NUMBER;
         v_dummy   NUMBER := 0;
         v_nsinies sin_siniestro.nsinies%TYPE;
         v_ntramit sin_tramita_pago.ntramit%TYPE;
         v_cestado sin_tramita_movimiento.cesttra%TYPE;
         v_sseguro sin_siniestro.sseguro%TYPE;
         v_nriesgo sin_siniestro.nriesgo%TYPE;
         v_detalle NUMBER;
         v_recibos NUMBER := 0;
         n_ctiprea NUMBER(1);
         vnerror   NUMBER;
      BEGIN
         v_usuario := f_user;

         SELECT t.isinret,
                s.cramo,
                s.sproduc,
                NVL(t.cmonres, e.cmoneda),
                DECODE(t.ctippag, 7, 2, 1),
                s.cempres,
                t.cconpag,
                i.nsinies,
                t.ntramit,
                i.sseguro,
                i.nriesgo,
                s.ctiprea
           INTO v_importe,
                v_cramo,
                v_sproduc,
                v_moneda,
                v_ctiplim,
                v_cempres,
                v_cconpag,
                v_nsinies,
                v_ntramit,
                v_sseguro,
                v_nriesgo,
                n_ctiprea -- Bug 28830 - 28/01/2014 - JTT
           FROM sin_tramita_pago t,
                sin_siniestro    i,
                seguros          s,
                eco_codmonedas   e
          WHERE t.nsinies = i.nsinies
            AND s.sseguro = i.sseguro
            AND t.sidepag = psidepag
            AND e.bdefecto = 1
            -- Inicio IAXIS-3178 -- ECP -- 25/04/2019
             and t.cmonres = e.cmoneda; 
            -- Fin IAXIS-3178 -- ECP -- 25/04/2019
         -- Bug 28830 - 28/01/2014 - JTT: No permitir crear nuevos movimientos en siniestros con recibos pendientes
         vpasexec := 2;

         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'VALIDAR_RECIBOS'),
                0) = 1
         THEN
            v_recibos := f_get_cartera_pendiente(v_sseguro, v_nriesgo);

            IF v_recibos <> 0
            THEN
               RETURN 9906450;
               -- No es permet generar nous pagaments amb rebuts pendents
            END IF;
         END IF;

         vpasexec := 3;
         -- Fi Bug 288830

         -- BUG 20014 - 19/01/2012 - JMP - No permitir crear nuevos pagos en siniestros o tramitaciones cerrados
         v_cestado := pac_siniestros.f_get_estado_siniestro(v_nsinies);

         IF v_cestado IN (1, 2, 3)
         THEN
            RETURN 9903145;
            -- No se permite generar nuevos pagos para un siniestro cerrado
         ELSE
            v_cestado := pac_siniestros.f_get_cesttra(v_nsinies, v_ntramit);

            IF v_cestado IN (1, 2, 3)
            THEN
               RETURN 9903144;
               -- No se permite generar nuevos pagos para una tramitación cerrada
            END IF;
         END IF;

         -- FIN BUG 20014 - 19/01/2012 - JMP - No permitir crear nuevos pagos en siniestros o tramitaciones cerrados

         -- 0026131:Validar exista detalle al hacer movimiento de pago : ASN: 18/02/2013 ini
         SELECT COUNT(*)
           INTO v_detalle
           FROM sin_tramita_pago_gar
          WHERE sidepag = psidepag;

         IF v_detalle = 0 AND
            pcestpag <> 8 --bug 28384/158328:NSS:12/11/2013
         THEN
            RETURN 9905004;
         END IF;

         -- 0026131:Validar exista detalle al hacer movimiento de pago : ASN: 18/02/2013 fin

         --Bug.: 19172 - ICV - 04/08/2011 - Comprobamos que pueda realizar la transición
         BEGIN
            SELECT stm.cestpag,
                   stm.cestval
              INTO v_cestant,
                   v_csubant
              FROM sin_tramita_movpago stm
             WHERE stm.sidepag = psidepag
               AND stm.nmovpag =
                   (SELECT MAX(nmovpag)
                      FROM sin_tramita_movpago stm2
                     WHERE stm.sidepag = stm2.sidepag);
         EXCEPTION
            WHEN OTHERS THEN
               v_cestant := NULL;
               v_csubant := NULL;
         END;

         BEGIN
            SELECT DISTINCT cnivper
              INTO v_cnivper
              FROM sin_codtramitador sc
             WHERE cusuari = f_user
               AND cempres = v_cempres
               AND cactivo = 1
               AND ctiptramit = 3; -- Bug 33298 - 04/11/2014 - JTT
         EXCEPTION
            WHEN no_data_found THEN
               v_cnivper := NULL;
            WHEN too_many_rows THEN
               v_cnivper := NULL;
         END;

         IF v_cnivper IS NULL
         THEN
            BEGIN
               SELECT MIN(cnivper)
                 INTO v_cnivper
                 FROM sin_codtramitador sc
                WHERE cusuari =
                      pac_parametros.f_parempresa_t(v_cempres, 'USER_BBDD')
                  AND cempres = v_cempres
                  AND cactivo = 1
                  AND ctiptramit = 3; -- Bug 33298 - 04/11/2014 - JTT
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 9902263;
            END;
         END IF;

         SELECT COUNT('1')
           INTO v_dummy
           FROM sin_transiciones st
          WHERE st.cempres = v_cempres
            AND st.cnivper = v_cnivper
            AND st.ctiptra = 1 --Pago
            AND st.cestsig = pcestpag
            AND (st.csubsig IS NULL OR st.csubsig = pcestval)
            AND st.cestant = v_cestant
            AND (st.csubant IS NULL OR st.csubant = v_csubant);

         IF v_dummy = 0
         THEN
            RETURN 9902264;
         END IF;

         --fi bug 19172
         -- Bug 29804 - 21/03/2014 - JTT: No validem el limit del usuari pels moviments de anul.lació (pcestpag = 8)
         IF pcestpag <> 8
         THEN
            BEGIN
               SELECT ilimite
                 INTO v_limite
                 FROM sin_tramita_pago_aut
                WHERE cusuari = v_usuario
                  AND cmonlim = v_moneda
                  AND ctlimit = v_ctiplim
                  AND sproduc = v_sproduc;
            p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_VALIDACIONES_SIN', 'F_MOVPAGO', NULL, 2, 'PASO 1, v_limite: '||
            v_limite||' v_usuario:'||v_usuario||' v_moneda:'||v_moneda||' v_ctiplim:'||v_ctiplim||' v_sproduc:'||v_sproduc);

            EXCEPTION
               WHEN no_data_found THEN
                  BEGIN
                     SELECT ilimite
                       INTO v_limite
                       FROM sin_tramita_pago_aut
                      WHERE cusuari = v_usuario
                        AND cmonlim = v_moneda
                        AND ctlimit = v_ctiplim
                        AND cramo = v_cramo
                        AND sproduc IS NULL;
                p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_VALIDACIONES_SIN', 'F_MOVPAGO', NULL, 2, 'PASO 2, v_limite: '||
            v_limite||' v_usuario:'||v_usuario||' v_moneda:'||v_moneda||' v_ctiplim:'||v_ctiplim||' v_cramo:'||v_cramo);

                  EXCEPTION
                     WHEN no_data_found THEN
                        BEGIN
                           SELECT ilimite
                             INTO v_limite
                             FROM sin_tramita_pago_aut
                            WHERE cusuari = v_usuario
                              AND cmonlim = v_moneda
                              AND ctlimit = v_ctiplim
                              AND cramo IS NULL
                              AND sproduc IS NULL;
                        p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_VALIDACIONES_SIN', 'F_MOVPAGO', NULL, 2, 'PASO 3, v_limite: '||
                        v_limite||' v_usuario:'||v_usuario||' v_moneda:'||v_moneda||' v_ctiplim:'||v_ctiplim);

                        EXCEPTION
                           WHEN no_data_found THEN
                              BEGIN
                                 SELECT ilimite
                                   INTO v_limite
                                   FROM sin_tramita_pago_aut s,
                                        parempresas          p
                                  WHERE s.cusuari = p.tvalpar
                                    AND s.cmonlim = v_moneda
                                    AND s.ctlimit = v_ctiplim
                                    AND p.cempres = v_cempres
                                    AND p.cparam = 'USER_BBDD'
                                    AND cramo IS NULL
                                    AND sproduc IS NULL;
                       p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_VALIDACIONES_SIN', 'F_MOVPAGO', NULL, 2, 'PASO 4, v_limite: '||
                        v_limite||' v_moneda:'||v_moneda||' v_ctiplim:'||v_ctiplim||' v_cempres:'||v_cempres);

                              EXCEPTION
                                 WHEN OTHERS THEN
                        p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_VALIDACIONES_SIN', 'F_MOVPAGO', NULL, 2, 'PASO 5, v_limite: '||
                        v_limite||' v_moneda:'||v_moneda||' v_ctiplim:'||v_ctiplim||' v_cempres:'||v_cempres||' v_usuario:'||v_usuario
                        ||' v_cramo:'||v_cramo||' v_sproduc:'||v_sproduc);

                                    NULL;
                              END;
                        END;
                  END;
            END;
            p_traza_proceso(24, 'TRAZA_CESIONES_REA', 777, 'PAC_VALIDACIONES_SIN', 'F_MOVPAGO', NULL, 2, 'PASO 6, v_limite: '||
            v_limite||' v_importe:'||v_importe);
            IF v_limite IS NULL OR
               NVL(v_limite, 0) < NVL(v_importe, 0)
            THEN
               RETURN 9901225;
               -- Autoritzación no permitida por limitación de Importe
            END IF;
         ELSE
            --No se pueden anular pagos ya pagados si la póliza es reasegurada
            IF NVL(v_cestant, 9) = 2 AND
               (pac_cesionesrea.producte_reassegurable(v_sproduc) = 1 OR
                n_ctiprea = 2)
            THEN
               RETURN 9908493;
            END IF;
         END IF; -- fI Bug 29804
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobjectname,
                        vpasexec,
                        vparam,
                        'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
            RETURN 9001437; --Error validar el moviment d''un pagament
      END; -- End Modificació JGM

      RETURN 0;
   END f_movpago;

   /*************************************************************************
      FUNCTION f_detpago
         Valida els detalls d'un pagament
         param in pnsinies  : Número sinistre
         param in pireserva : Importe reserva
         param in pisinret  : Importe sin retención
         param in piiva     : Importe IVA
         param in piretenc  : Importe brut
         param in pfperini  : Fecha inicio
         param in pfperfin  : Fecha fin
         param in piresrcm  : Import Rendiment obligatori
         param in piresred  : Import Rendiment Reduït obligatori
         param in pctipres  : Tipo de reserva
         param in pcgarant  : Codigo de la garantia
         param in pctippag  : Tipo de pago
         param in pcmonres  : Moneda de la reserva contra la que va el pago
         param in psidepag  : Id. del pago
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 14608 - 27/05/2010 - AMC - Se añaden nuevos parametros
   *************************************************************************/
   FUNCTION f_detpago(pnsinies  IN VARCHAR2,
                      pireserva IN NUMBER,
                      pisinret  IN NUMBER,
                      piiva     IN NUMBER,
                      piretenc  IN NUMBER,
                      pfperini  IN DATE,
                      pfperfin  IN DATE,
                      piresrcm  IN NUMBER,
                      piresred  IN NUMBER,
                      pctipres  IN NUMBER,
                      pcgarant  IN NUMBER,
                      pctippag  IN NUMBER,
                      pcmonres  IN VARCHAR2, -- BUG 18423 - 16/01/2012 - JMP - Multimoneda
                      psidepag  IN NUMBER, -- BUG 18423 - 16/01/2012 - JMP - Multimoneda
                      pctipgas  IN NUMBER, --27909:NSS:03/09/2013
                      pcconpag  IN NUMBER,
                      pnmovres  IN NUMBER, --BUG 31294/174788:NSS:29/05/2014
                      pnorden   IN NUMBER, --BUG 31294/174788:NSS:29/05/2014
                      pireteiva IN NUMBER, --BUG 24637/147756:NSS:29/05/2014
                      pireteica IN NUMBER, --BUG 24637/147756:NSS:29/05/2014
                      pitotimp  IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:14/03/2014
                      pitotret  IN NUMBER DEFAULT NULL, --bug 24637/147756:NSS:21/03/2014
                      piotrosgas IN NUMBER DEFAULT NULL,
                      pibaseipoc IN NUMBER DEFAULT NULL,
                      piipoconsumo IN NUMBER DEFAULT NULL
                      ) RETURN NUMBER IS
      vobjectname  VARCHAR2(500) := 'pac_validaciones_sin.f_detpago';
      vparam       VARCHAR2(500) := 'parámetros - pnsinies:' || pnsinies ||
                                    ' pireserva:' || pireserva ||
                                    ' pisinret:' || pisinret || ' piiva:' ||
                                    piiva || ' piretenc:' || piretenc ||
                                    ' pfperini:' || pfperini ||
                                    ' pfperfin:' || pfperfin ||
                                    ' piresrcm:' || piresrcm ||
                                    ' piresred:' || piresred ||
                                    ' pctipres:' || pctipres ||
                                    ' pcgarant:' || pcgarant ||
                                    ' pctippag:' || pctippag ||
                                    ' pcmonres: ' || pcmonres ||
                                    ' psidepag: ' || psidepag ||
                                    ' pctipgas: ' || pctipgas ||
                                    ' pcconpag: ' || pcconpag ||
                                    ' pitotimp: ' || pitotimp --bug 24637/147756:NSS:14/03/2014
                                    || ' pitotret: ' || pitotret --bug 24637/147756:NSS:21/03/2014
                                    || ' pnorden: ' || pnorden ||
                                    ' pnmovres: ' || pnmovres ||
                                    ' pireteiva: ' || pireteiva ||
                                    ' pireteica: ' || pireteica;
      vpasexec     NUMBER(5) := 1;
      vcestpag_ant NUMBER(1);
      v_sproduc    NUMBER;
      v_cramo      NUMBER;
      v_cmodali    NUMBER;
      v_ctipseg    NUMBER;
      v_ccolect    NUMBER;
      v_cactivi    NUMBER;
      v_es_baja    NUMBER;
      v_cempres    seguros.cempres%TYPE;
      v_cmonres_p  sin_tramita_pago.cmonres%TYPE;
      vcconcep     NUMBER;
      vcuantos     NUMBER;
      v_validar    NUMBER := 1;
      v_ctipdes    NUMBER;
      visinret     sin_tramita_pago_gar.isinret%TYPE;
      --bug 31294/174788:NSS:14/03/2014
      viretenc sin_tramita_pago_gar.iretenc%TYPE;
      --bug 31294/174788:NSS:14/03/2014
      viiva sin_tramita_pago_gar.iiva%TYPE;
      --bug 31294/174788:NSS:14/03/2014
      vireteiva sin_tramita_pago_gar.ireteiva%TYPE;
      --bug 31294/174788:NSS:14/03/2014
      vireteica sin_tramita_pago_gar.ireteica%TYPE;
      --bug 31294/174788:NSS:14/03/2014
      vireserva NUMBER; --bug 31294/174788:NSS:14/03/2014
      vitotimp  NUMBER; --bug 31294/174788:NSS:14/03/2014
      vitotret  NUMBER; --bug 31294/174788:NSS:14/03/2014
      viotrosgas NUMBER;
      vibaseipoc NUMBER;
      viipoconsumo NUMBER;

   BEGIN
      --Ini 27909:NSS:03/09/2013
      BEGIN
         SELECT cconcep
           INTO vcconcep
           FROM sin_pag_concepto
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN no_data_found THEN
            v_validar := 0;
      END;

      BEGIN
         SELECT cconcep
           INTO vcconcep
           FROM sin_res_concepto
          WHERE ROWNUM = 1;
      EXCEPTION
         WHEN no_data_found THEN
            v_validar := 0;
      END;

      IF v_validar = 1
      THEN
         BEGIN
            SELECT cconcep
              INTO vcconcep
              FROM sin_pag_concepto
             WHERE cconpag = pcconpag;
         EXCEPTION
            WHEN no_data_found THEN
               RETURN 9905951;
         END;

         vpasexec := 2;

         IF pctipgas IS NOT NULL
         THEN
            BEGIN
               SELECT COUNT(*)
                 INTO vcuantos
                 FROM sin_res_concepto
                WHERE cconcep = vcconcep
                  AND ctipres = pctipres
                  AND ctipgas = pctipgas;
            EXCEPTION
               WHEN no_data_found THEN
                  RETURN 9905951;
            END;
         ELSE
            BEGIN
               SELECT COUNT(*)
                 INTO vcuantos
                 FROM sin_res_concepto
                WHERE cconcep = vcconcep
                  AND ctipres = pctipres;
            EXCEPTION
               WHEN no_data_found THEN
                  RETURN 9905951;
            END;
         END IF;

         vpasexec := 3;

         IF vcuantos < 1
         THEN
            RETURN 9905951;
         END IF;
      END IF;

      --Fin 27909:NSS:03/09/2013
      IF pireserva IS NULL
      THEN
         RETURN 9001415; -- Import Reserva obligatori
      END IF;

      -- BUG15171:DRA:28/06/2010:Inici
      IF NVL(pisinret, 0) = 0
      THEN
         RETURN 9901261; -- Falta l'import de pagament brut
      END IF;

      -- BUG15171:DRA:28/06/2010:Fi

      -- Si es baja tiene que tenet inicio y fin
      SELECT seg.cramo,
             seg.cmodali,
             seg.ctipseg,
             seg.ccolect,
             seg.cactivi,
             seg.cempres
        INTO v_cramo,
             v_cmodali,
             v_ctipseg,
             v_ccolect,
             v_cactivi,
             v_cempres
        FROM sin_siniestro sini,
             seguros       seg
       WHERE sini.nsinies = pnsinies
         AND seg.sseguro = sini.sseguro;

      --Ini 27487:NSS:25/11/2013
      SELECT ctipdes
        INTO v_ctipdes
        FROM sin_tramita_pago
       WHERE sidepag = psidepag;

      IF v_ctipdes = 1 AND
         f_pargaranpro_v(v_cramo,
                         v_cmodali,
                         v_ctipseg,
                         v_ccolect,
                         v_cactivi,
                         pcgarant,
                         'MUERTE') = 1
      THEN
         RETURN 9906306;
      END IF;

      --Fin 27487:NSS:25/11/2013
      v_es_baja := f_pargaranpro_v(v_cramo,
                                   v_cmodali,
                                   v_ctipseg,
                                   v_ccolect,
                                   v_cactivi,
                                   pcgarant,
                                   'BAJA');

      -- Bug 30843 - 01/04/2014 - JTT:  Unicamente validamos las fechas para las reservas indemnizatorias
      IF v_es_baja = 1 AND
         pctipres = 1
      THEN
         IF pfperini IS NULL OR
            pfperfin IS NULL
         THEN
            RETURN 9901215; --Fecha Inicio y Fin obligatoria
         END IF;
      END IF;

      IF pctippag <> 7
      THEN
         --ini bug 31294/174788:NSS:29/05/2014
         BEGIN
            SELECT NVL(isinret, 0),
                   NVL(iretenc, 0),
                   NVL(iiva, 0),
                   NVL(ireteiva, 0),
                   NVL(ireteica, 0),
                   NVL(iotrosgas, 0),
                   NVL(ibaseipoc, 0),
                   NVL(iipoconsumo, 0)
              INTO visinret,
                   viretenc,
                   viiva,
                   vireteiva,
                   vireteica,
                   viotrosgas,
                   vibaseipoc,
                   viipoconsumo
              FROM sin_tramita_pago_gar sg
             WHERE sidepag = psidepag
               AND ctipres = pctipres
               AND nmovres = pnmovres
               AND norden = pnorden;
         EXCEPTION
            WHEN no_data_found THEN
               vireserva := pireserva;
               vitotimp  := pitotimp;
               vitotret  := pitotret;
         END;

         /*  Si existe el detalle del pago quiere decir que se trata de una modificación del detalle del pago,
         *  por lo tanto validamos la reserva pendiente con el importe anterior
         */
         IF visinret IS NOT NULL
         THEN
            vireserva := pireserva + visinret;
            vitotimp  := pitotimp + viiva + viotrosgas + vibaseipoc + viipoconsumo;
            vitotret  := pitotret + viretenc + vireteiva + vireteica;
         END IF;

         --fin bug 31294/174788:NSS:29/05/2014

         -- Bug 17354 - RSC - 21/01/2011 - INCLOURE FACTURES DESPESES JUDICIS EN SINISTRES (Añadimos: - NVL(piretenc, 0))
         IF NVL(vitotimp, 0) > 0 OR
            NVL(vitotimp, 0) > 0
         THEN
            IF (NVL(pisinret, 0) -
               (NVL(piretenc, 0) + NVL(pireteiva, 0) + NVL(pireteica, 0)) +
               NVL(piiva, 0) + NVL(piotrosgas, 0) + NVL(pibaseipoc, 0) + NVL(piipoconsumo, 0)) > (NVL(vireserva, 0) + NVL(vitotimp, 0) -
               --bug 24637/147756:NSS:14/03/2014 --31294/174788:NSS:29/05/2014
               NVL(vitotret, 0))
            THEN
               --bug 24637/147756:NSS:21/03/2014 --31294/174788:NSS:29/05/2014
               RETURN 9901216;
            END IF;
         ELSE
	    --IAXIS-4555 Validación de otros gastos en pagos de tiquetes aereos
            IF (NVL(pisinret, 0) + NVL(piotrosgas, 0)) > NVL(vireserva, 0)
            THEN
               --bug 24637/147756:NSS:21/03/2014 --31294/174788:NSS:29/05/2014
               RETURN 9901216;
            END IF;
	    --IAXIS-4555 Validación de otros gastos en pagos de tiquetes aereos
         END IF;
      END IF;

      -- BUG 18423 - 17/01/2012 - JMP - Multimoneda
      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1
      THEN
         IF pcmonres IS NOT NULL AND
            psidepag IS NOT NULL
         THEN
            BEGIN
               SELECT DISTINCT cmonres
                 INTO v_cmonres_p
                 FROM sin_tramita_pago_gar
                WHERE sidepag = psidepag;
            EXCEPTION
               WHEN no_data_found THEN
                  v_cmonres_p := pcmonres;
            END;

            IF pcmonres <> v_cmonres_p
            THEN
               RETURN 9903122;
               -- La reserva y el pago deben estar en la misma moneda
            END IF;
         END IF;
      END IF;

      -- FIN BUG 18423 - 17/01/2012 - JMP - Multimoneda

      --
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001437; --Error validar el moviment d''un pagament
   END f_detpago;

   /*************************************************************************
      FUNCTION f_agenda
         Valida l'agenda
         param in pctipreg  : Codi tipo registro
         param in pcmanual  : Codi manual
         param in pcestage  : Codi estat agenda
         param in pffinage  : Data finalització
         param in pcestage  : Títol
         param in ptlinage  : Descripció
         param in psidepag  : Seqüéncia pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_agenda(pctipreg IN NUMBER,
                     pcmanual IN NUMBER,
                     pcestage IN NUMBER,
                     pffinage IN DATE,
                     pttitage IN VARCHAR2,
                     ptlinage IN VARCHAR2,
                     psidepag IN NUMBER) RETURN NUMBER IS
      vobjectname  VARCHAR2(500) := 'pac_validaciones_sin.f_agenda';
      vparam       VARCHAR2(500) := 'parámetros - pctipreg:' || pctipreg ||
                                    ' pcmanual:' || pcmanual ||
                                    ' pcestage:' || pcestage ||
                                    ' pffinage:' || pffinage ||
                                    ' pttitage:' || pttitage ||
                                    ' ptlinage:' || ptlinage;
      vpasexec     NUMBER(5) := 1;
      vcestpag_ant NUMBER(1);
   BEGIN
      IF pctipreg IS NULL
      THEN
         RETURN 9001455; --Tipus Apunt obligatori
      END IF;

      IF pcmanual IS NULL
      THEN
         RETURN 9001456; --Introducció obligatori
      END IF;

      IF pcestage IS NULL
      THEN
         RETURN 9001457; --Codi Estat Agenda obligatori
      END IF;

      IF pcestage = 1 AND
         pffinage IS NULL
      THEN
         RETURN 9001458; --Data Finalització obligatoria
      END IF;

      IF pttitage IS NULL
      THEN
         RETURN 9001459; --Títol obligatori
      END IF;

      IF ptlinage IS NULL
      THEN
         RETURN 9001460; --Descripció obligatoria
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001437; --Error validar el moviment d''un pagament
   END f_agenda;

   /*************************************************************************
      FUNCTION f_calcimporteres
         Valida los parametros para poder calcular el importe de la reserva
         param in pctipres  : Codi tipo reserva
         param in pcgarang  : Codigo de la garantia
         param in pfresini  : Fecha de inicio reserva
         param in pfresfin  : Fecha fin de reserva
         param in psproduc  : Codigo del producto
         mensajes           : Mensajes de error
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

      Bug 12207 - 02/02/2010 - AMC
   *************************************************************************/
   FUNCTION f_calcimporteres(pctipres IN NUMBER,
                             pcgarant IN NUMBER,
                             pfresini IN DATE,
                             pfresfin IN DATE,
                             psproduc IN NUMBER) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_agenda';
      vparam      VARCHAR2(500) := 'parámetros - pctipres:' || pctipres ||
                                   ' pcgarant:' || pcgarant || ' pfresini:' ||
                                   pfresini || ' pfresfin:' || pfresfin ||
                                   ' psproduc:' || psproduc;
      vpasexec    NUMBER(5) := 1;
      vvalpar     NUMBER;
      vnumerr     NUMBER;
   BEGIN
      IF pctipres IS NULL
      THEN
         RETURN 9900979; --Tipus reserva obligatori
      END IF;

      IF pctipres = 1 AND
         pcgarant IS NULL
      THEN
         RETURN 9001413; --Garantia obligatoria
      END IF;

      IF pcgarant IS NOT NULL
      THEN
         vnumerr := pac_productos.f_get_pargarantia('BAJA',
                                                    psproduc,
                                                    pcgarant,
                                                    vvalpar);

         IF vvalpar = 1
         THEN
            IF pfresini IS NULL
            THEN
               RETURN 105308; --Fecha inicial obligatoria
            END IF;

            IF pfresfin IS NULL
            THEN
               RETURN 9001419; --Fecha Fin obligatoria
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_calcimporteres;

   -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)

   /*************************************************************************
      FUNCTION f_prest
         Valida les dades de la prestació en forma de renda
         param in pnsinies  : Número de sinistre
         param in pntramit  : Número de tramitació
         param in psperson  : Codi persona
         param in pctipdes  : Tipus destinatari
         param in psseguro  : Sseguro
                  param in F1PAREN  : Fecha primera renta
        param in FUPAREN   : Fecha ultima renta
        param in CFORPAG : Forma pago renta
        param in IBRUREN   :Importe renta
        param in CREVALI   : Tipo revalorización
        param in PREVALI   : % revalorización
        param in IREVALI   : Importe revalorización
        param in CTIPDUR   : Tipo duración
        param in NPARTOT : Participaciones inciales
        param in CTIPBAN   : Tipo Banc
        param in CBANCAR   :Cuenta

         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_prest(pnsinies IN VARCHAR2,
                    pntramit IN NUMBER,
                    psperson IN NUMBER,
                    pctipdes IN NUMBER,
                    psseguro IN NUMBER,
                    pf1paren IN DATE,
                    pfuparen IN DATE,
                    pcforpag IN NUMBER,
                    pibruren IN NUMBER,
                    pcrevali IN NUMBER,
                    pprevali IN NUMBER,
                    pirevali IN NUMBER,
                    pctipdur IN NUMBER,
                    pnpartot IN NUMBER,
                    pctipban IN NUMBER,
                    pcbancar IN VARCHAR2,
                    pcestado IN NUMBER,
                    pcmotivo IN NUMBER,
                    pcblopag IN NUMBER,
                    pnpresta IN NUMBER) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_prest';
      vparam      VARCHAR2(2000) := 'parámetros - pnsinies:' || pnsinies ||
                                    ' pntramit:' || pntramit ||
                                    ' psseguro:' || psseguro ||
                                    ' pctipdes:' || pctipdes || ' F1PAREN:' ||
                                    TO_CHAR(pf1paren, 'DD/MM/YYYY') ||
                                    ' psperson:' || psperson || ' FUPAREN:' ||
                                    TO_CHAR(pfuparen, 'DD/MM/YYYY') ||
                                    ' CFORPAG:' || pcforpag || ' IBRUREN:' ||
                                    pibruren || ' pCREVALI:' || pcrevali ||
                                    ' PREVALI:' || pprevali || ' CTIPDUR:' ||
                                    pctipdur || ' NPARTOT:' || pnpartot ||
                                    ' CTIPBAN:' || pctipban || ' pcbancar:' ||
                                    pcbancar || ' pnpresta:' || pnpresta;
      vpasexec    NUMBER(5) := 1;
      vesvida     VARCHAR2(1) := 'N';
      --Indica si és un sinistre de vida
      -- BUG 0015669 - 08/2010 - JRH  -  Alta prestacions en forma de renda (PL)
      vnum            NUMBER;
      vfecsini        DATE;
      reg_prestaren   prestaren%ROWTYPE;
      vexiteprestaren BOOLEAN := FALSE;
      vexitepagosrent BOOLEAN := FALSE;
      -- Fi BUG 0015669 - 08/2010 - JRH
      v_cestsin sin_movsiniestro.cestsin%TYPE;
      -- Bug 18286 - APD - 21/04/2011
   BEGIN
      IF pctipdes IS NULL
      THEN
         RETURN 9001420; --Tipus Destinatari obligatori'
      END IF;

      vpasexec := 1;

      IF psperson IS NULL
      THEN
         RETURN 9000941; --Camp Destinatari obligatori
      END IF;

      vpasexec := 2;

      IF NVL(pibruren, 0) = 0
      THEN
         --Import obligatori
         RETURN 9901337;
      END IF;

      vpasexec := 3;

      IF pf1paren IS NULL
      THEN
         RETURN 9901387;
      END IF;

      vpasexec := 4;

      BEGIN
         SELECT fsinies
           INTO vfecsini
           FROM sin_siniestro
          WHERE nsinies = pnsinies;

         IF pf1paren < vfecsini
         THEN
            RETURN 9901388;
         END IF;
      EXCEPTION
         WHEN no_data_found THEN
            vfecsini := NULL;
      END;

      vpasexec := 5;

      IF pctipdur IS NULL
      THEN
         RETURN 9901389;
      END IF;

      vpasexec := 6;

      SELECT COUNT(*)
        INTO vnum
        FROM detvalores
       WHERE cvalor = 1010
         AND catribu = pctipdur;

      vpasexec := 7;

      IF vnum = 0
      THEN
         RETURN 9901390;
      END IF;

      vpasexec := 8;

      IF pctipdur = 1
      THEN
         IF pfuparen IS NOT NULL
         THEN
            RETURN 9901391;
         END IF;
      END IF;

      vpasexec := 9;

      IF pctipdur = 2
      THEN
         IF pfuparen IS NULL
         THEN
            RETURN 105554;
         END IF;

         IF pf1paren > pfuparen
         THEN
            RETURN 120084;
         END IF;
      END IF;

      vpasexec := 10;

      IF pctipdur = 3
      THEN
         IF pfuparen IS NOT NULL
         THEN
            RETURN 9901391;
         END IF;

         IF pnpartot IS NULL
         THEN
            RETURN 105953;
         END IF;
      END IF;

      vpasexec := 11;

      IF pcforpag IS NULL
      THEN
         RETURN 100733;
      END IF;

      vpasexec := 12;

      SELECT COUNT(*)
        INTO vnum
        FROM detvalores
       WHERE cvalor = 17
         AND catribu = pcforpag;

      vpasexec := 13;

      IF vnum = 0
      THEN
         RETURN 140704;
      END IF;

      IF NVL(pcrevali, 0) = 0
      THEN
         IF NVL(pprevali, 0) <> 0 OR
            NVL(pirevali, 0) <> 0
         THEN
            RETURN 9901392;
         END IF;
      END IF;

      vpasexec := 14;

      BEGIN
         SELECT *
           INTO reg_prestaren
           FROM prestaren
          WHERE nsinies = pnsinies
            AND ntramit = pntramit
            AND sperson = psperson
            AND ctipdes = pctipdes
            AND npresta = pnpresta;

         vexiteprestaren := TRUE;
      EXCEPTION
         WHEN no_data_found THEN
            vexiteprestaren := FALSE;
      END;

      vpasexec := 15;

      IF vexiteprestaren
      THEN
         BEGIN
            SELECT 1
              INTO vnum
              FROM pagosrenta
             WHERE sseguro = reg_prestaren.sseguro
               AND sperson = reg_prestaren.sperson;

            vexitepagosrent := TRUE;
         EXCEPTION
            WHEN no_data_found THEN
               vexitepagosrent := FALSE;
               -- Bug 0016455 - JRH - 22/11/2010 - 0016455: ENSA101 - Controlar más filas
            WHEN too_many_rows THEN
               vexitepagosrent := TRUE;
               -- Fi Bug 0016455 - JRH - 22/11/2010
         END;
      END IF;

      vpasexec := 16;

      IF vexiteprestaren AND
         vexitepagosrent AND
         NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'MULTI_RENTA'),
             0) = 0
      THEN
         --Si ya se han generado rentas
         vpasexec := 17;

         IF NVL(pcrevali, 0) <> NVL(reg_prestaren.crevali, 0) OR
            NVL(pirevali, 0) <> NVL(reg_prestaren.irevali, 0) OR
            NVL(pprevali, 0) <> NVL(reg_prestaren.prevali, 0) OR
            NVL(pprevali, 0) <> NVL(reg_prestaren.prevali, 0) OR
            NVL(pf1paren, TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
            NVL(reg_prestaren.f1paren, TO_DATE('01/01/1900', 'DD/MM/YYYY')) OR
            NVL(pfuparen, TO_DATE('01/01/1900', 'DD/MM/YYYY')) <>
            NVL(reg_prestaren.fuparen, TO_DATE('01/01/1900', 'DD/MM/YYYY')) OR
            NVL(pcforpag, 0) <> NVL(reg_prestaren.cforpag, 0) OR
            NVL(pctipdur, 0) <> NVL(reg_prestaren.ctipdur, 0)
         THEN
            RETURN 9901541;
         END IF;
      END IF;

      -- Se valida el estado de la prestacion
      -- Bug 18286 - APD - 20/04/2011 -
      -- Si el estado del siniestros es 0.-Abierto o 5.-Presiniestro
      -- el estado de la prestacion solo puede ser 4.-Pendiente de Activar
      -- o 0.-Activa
      v_cestsin := pac_siniestros.f_get_estado_siniestro(pnsinies);

      -- jlb -i - Jlb - 26776 - ENSA
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                           'MODIF_PRESTA'),
             1) = 1
      THEN
         IF v_cestsin IN (0, 5)
         THEN
            IF NVL(pcestado, 0) NOT IN (4, 0)
            THEN
               RETURN 110300;
            END IF;
            -- Si el estado del siniestros es 2.-Anulado o 5.-Rechazado
            -- el estado de la prestacion solo puede ser 5.-Anular sin Activar
         ELSIF v_cestsin IN (2, 3)
         THEN
            IF NVL(pcestado, 0) <> 5
            THEN
               RETURN 110300;
            END IF;
            -- Si el estado del siniestro es 4.-ReAbierto y no existe la prestacion
            -- (se esta´dando de alta una prestacion) o
            -- si el estado del siniestro es 4.-Reabierto y existe la prestacion
            -- y el estado de la prestacion es 4.-Pendiente de activar,
            -- el estado de la prestacion solo puede ser 4.-Pendiente de Activar
            -- o 0.-Activa
         ELSIF (v_cestsin = 4 AND NOT vexiteprestaren) OR
               (v_cestsin = 4 AND vexiteprestaren AND
               NVL(reg_prestaren.cestado, 4) = 4)
         THEN
            IF NVL(pcestado, 0) NOT IN (4, 0)
            THEN
               RETURN 110300;
            END IF;
         ELSE
            -- Si el estado del siniestro es cualquier otro, el estado de la prestacion
            -- no puede ser ni 4.-Pendiente de Activar ni 5.-Anular sin Activar
            IF NVL(pcestado, 0) IN (4, 5)
            THEN
               RETURN 110300;
            END IF;
         END IF;
      END IF;

      -- jlb -F - Jlb - 26776 - ENSA
      -- fin Bug 18286 - APD - 20/04/2011
      IF NVL(reg_prestaren.cestado, 0) <> NVL(pcestado, 0)
      THEN
         -- Bug 18286 - APD - 26/04/2011
         -- Si se permite pasar del estado 0.-Activa a 1.-Inactiva
         /*IF NVL(reg_prestaren.cestado, 0) = 0
            AND pcestado = 1 THEN
            RETURN 110300;
         END IF;
         */
         -- fin Bug 18286 - APD - 26/04/2011
         IF NVL(reg_prestaren.cestado, 0) = 3
         THEN
            -- Finalizada
            RETURN 110300;
         END IF;
      END IF;

      -- Bug 18286 - APD - 21/04/2011 - el estado de los pagos solo puede ser
      -- 0.-Pendiente de pago, 1.-Pagado, 5.-Pendiente Bloqueado
      IF pcblopag NOT IN (0, 1, 5)
      THEN
         RETURN 9901159; -- Estado del pago invalido
      END IF;

      -- Fin Bug 18286 - APD - 21/04/2011
      -- ini Bug 0017970 - 16/03/2011 - JMF
      -- validar que si introducimos una prestación, el campo ctipcap de sin_tramita_destinatario vale 1 o 3.
      SELECT NVL(MAX(1), 0)
        INTO vnum
        FROM sin_siniestro            a,
             sin_tramita_destinatario c
       WHERE a.nsinies = pnsinies
         AND c.nsinies = a.nsinies
         AND c.ntramit = pntramit
         AND c.sperson = psperson
         AND c.ctipdes = pctipdes
         AND NVL(c.ctipcap, -1) NOT IN (1, 3);

      IF vnum = 1
      THEN
         -- Tipus de prestació errònia
         RETURN 9901287;
      END IF;

      -- fin Bug 0017970 - 16/03/2011 - JMF
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901518; --Error validar destinatari
   END f_prest;

   -- Fi BUG 0015669 - 08/2010 - JRH

   -- Ini bug 18554 - 07/06/2011 - SRA
   FUNCTION f_cabecerasini2(pnsinies IN sin_siniestro.nsinies%TYPE,
                            pfsinact IN sin_siniestro.fsinies%TYPE,
                            -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
                            -- mensajes IN OUT t_iax_mensajes)
                            terror OUT tab_error.terror%TYPE) RETURN NUMBER IS
      vsseguro         sin_siniestro.sseguro%TYPE;
      vfsinant         sin_siniestro.fsinies%TYPE;
      vtlistagarantias VARCHAR2(500);
      vcidioma         NUMBER;
      vobject          VARCHAR2(100) := 'PAC_VALIDACIONES_SIN.F_CABECERASINI2';
      vpasexec         NUMBER := 0;
      vparam           VARCHAR2(2000) := 'pnsinies: ' || pnsinies || ' - ' ||
                                         'vfsinact: ' || pfsinact;

      -- Tramitacions en estat 'actiu'
      CURSOR c_gar_sin IS
         SELECT DISTINCT str.cgarant,
                         str.ntramit
           FROM sin_tramita_reserva str
          WHERE str.nsinies = pnsinies
            AND str.cgarant IS NOT NULL
            AND pac_siniestros.f_get_cesttra(str.nsinies, str.ntramit) NOT IN
                (2, 3)
          ORDER BY str.cgarant;
   BEGIN
      IF pnsinies IS NULL
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9001940, vpasexec, vparam);
         RETURN 9001940; -- 'No existeix el num. de sinistre'
      END IF;

      IF pfsinact IS NULL
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9000640, vpasexec, vparam);
         RETURN 9000640; -- 'Falta informar la data del sinistre'
      END IF;

      vpasexec := 1;
      vcidioma := f_usu_idioma;
      vpasexec := 2;

      BEGIN
         SELECT si.sseguro,
                si.fsinies
           INTO vsseguro,
                vfsinant
           FROM sin_siniestro si
          WHERE si.nsinies = pnsinies;
      EXCEPTION
         WHEN no_data_found THEN
            -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
            -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9001940, vpasexec, vparam);
            RETURN 9001940; -- 'No existeix el num. de sinistre'
      END;

      --------------------------------------------------------------------------------------------------------------------------
      -- 4 Comprovem si existeixen garanties que estiguin actives, que tinguin pagaments pendents però que si es fes el canvi
      -- a la nova data d'ocurrència deixarien d'estar vigents
      -------------------------------------------------------------------------------------------------------------------------
      terror           := NULL;
      vtlistagarantias := NULL;
      vpasexec         := 3;

      -- 4.1) Recuperem les garanties associades a tramitacions actives
      FOR i IN c_gar_sin
      LOOP
         DECLARE
            vncgarant garangen.cgarant%TYPE;
            vtgarant  garangen.tgarant%TYPE;
            vnpagos   NUMBER;
            vnresult  NUMBER;
            e_siguiente EXCEPTION;
         BEGIN
            vpasexec := 4;

            -- 4.2) Comprovem si la garantia esta vigent en l'antiga data d'ocurrència i te alguna tramitació amb pagaments no anul.lats
            SELECT COUNT(stp.sidepag)
              INTO vnpagos
              FROM sin_tramita_pago     stp,
                   sin_tramita_pago_gar stpg
             WHERE stp.sidepag = stpg.sidepag
               AND stp.ntramit = i.ntramit
               AND stp.nsinies = pnsinies
               AND stpg.cgarant = i.cgarant
                  -- la garantia te pagaments no anul.lats
               AND pac_siniestros.f_get_cestpag(stp.sidepag) != 8
                  -- la garantia està vigent abans del canvi en la data d'ocurrència
               AND EXISTS
             (SELECT DISTINCT cgarant
                      FROM garanseg
                     WHERE sseguro = vsseguro
                       AND cgarant = stpg.cgarant
                       AND vfsinant BETWEEN finiefe AND
                           NVL(ffinefe, TO_DATE('31/12/9999', 'dd/mm/yyyy')));

            IF vnpagos = 0
            THEN
               RAISE e_siguiente;
               -- Si la garantia no te pagaments pendents, passem a la següent garantia
            END IF;

            vpasexec := 5;

            -- 4.3) Comprovem si en la nova data d'ocurrència del sinistre, aquestes garanties amb pagaments pendents deixarien
            -- d'estar vigents
            SELECT DISTINCT cgarant
              INTO vncgarant
              FROM garanseg
             WHERE sseguro = vsseguro
               AND cgarant = i.cgarant
               AND pfsinact BETWEEN finiefe AND
                   NVL(ffinefe, TO_DATE('31/12/9999', 'dd/mm/yyyy'));
         EXCEPTION
            -- La garantia (amb pagaments pendents) no està vigent en la nova data d'ocurrència, pel que composem
            -- un missatge que informi de quines garanties han variat capital
            WHEN no_data_found THEN
               vpasexec := 6;
               vnresult := f_desgarantia(i.cgarant, vcidioma, vtgarant);

               IF vnresult != 0
               THEN
                  -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
                  -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9902067, vpasexec, vparam);
                  RETURN 9902067;
               ELSE
                  vpasexec         := 7;
                  vtlistagarantias := SUBSTR(vtlistagarantias || vtgarant || ', ',
                                             1,
                                             500);
                  -- "Mort, Mort en Accident,..."
               END IF;
            WHEN e_siguiente THEN
               NULL;
            WHEN OTHERS THEN
               terror := 'i.cgarant = ' || i.cgarant || ': ';
               RAISE;
         END;
      END LOOP;

      vpasexec := 8;

      IF vtlistagarantias IS NOT NULL
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         --         vpasexec := 9;
         terror := f_axis_literales(9902076, f_usu_idioma);
         -- 'La/Les garantia/ies: #1tenen pagaments pendents i no estan contractades en la nova data d'ocurrència
         terror := REPLACE(terror, '#1', vtlistagarantias);
         --         vpasexec := 10;
         --         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, vterror);
         --         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 5, 9902076, vterror);
         RETURN 9902076;
      END IF;

      ----------------------------------------------------------------------------------------------------------------
      -- 1 Comprovem que les garanties associades a tramitacions actualment actives, estaran vigents en la nova data
      -- d'ocurrència del sinistre
      ----------------------------------------------------------------------------------------------------------------
      vpasexec         := 11;
      terror           := NULL;
      vtlistagarantias := NULL;

      -- 1.1) Recuperem les garanties associades a tramitacions actives
      FOR i IN c_gar_sin
      LOOP
         DECLARE
            vnmaxmov garanseg.nmovimi%TYPE;
            vtgarant garangen.tgarant%TYPE;
            vnresult NUMBER;
         BEGIN
            vpasexec := 12;

            -- 1.2) Comprovem si la garantia activa està vigent en la nova data d'ocurrència del sinistre
            SELECT MAX(g2.nmovimi)
              INTO vnmaxmov
              FROM garanseg      g2,
                   sin_siniestro s
             WHERE g2.sseguro = s.sseguro
               AND s.nsinies = pnsinies
               AND g2.cgarant = i.cgarant
               AND pfsinact BETWEEN g2.finiefe AND
                   NVL(g2.ffinefe, TO_DATE('31/12/9999', 'DD/MM/YYYY'));

            IF vnmaxmov IS NULL
            THEN
               vpasexec := 13;
               vnresult := f_desgarantia(i.cgarant, vcidioma, vtgarant);

               IF vnresult != 0
               THEN
                  -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
                  -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9902067, vpasexec,vparam);
                  RETURN 9902067;
               ELSE
                  vpasexec         := 14;
                  vtlistagarantias := SUBSTR(vtlistagarantias || vtgarant || ', ',
                                             1,
                                             500);
                  -- "Mort, Mort en Accident,..."
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               terror := 'i.cgarant = ' || i.cgarant || ': ';
               RAISE;
         END;
      END LOOP;

      vpasexec := 15;

      IF vtlistagarantias IS NOT NULL
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         --         vpasexec := 16;
         terror := f_axis_literales(9902068, f_usu_idioma);
         -- 'La/Les garantia/ies: #1tenen pagaments pendents i no estan contractades en la nova data d'ocurrència
         terror := REPLACE(terror, '#1', vtlistagarantias);
         --         vpasexec := 17;
         --         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, vterror);
         --         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 5, 9902068, vterror);
         RETURN 9902068;
      END IF;

      -------------------------------------------------------------------------------------------------------------------------
      -- 2 Comprovem si el canvi en la data d'ocurrència comporta un canvi en els capitals de les garanties afectades actives
      -------------------------------------------------------------------------------------------------------------------------
      vpasexec         := 18;
      terror           := NULL;
      vtlistagarantias := NULL;

      -- 2.1) Recuperem les garanties associades a tramitacions actives
      FOR i IN c_gar_sin
      LOOP
         DECLARE
            vtgarant garangen.tgarant%TYPE;
            vnresult NUMBER;
         BEGIN
            vpasexec := 19;

            -- 2.2) D'entre les garanties actives, recuperem aquelles que a mes d'estar vigents en les dates d'ocurrència
            -- (l'anterior i l'actual) pateixen un canvi en l'import de garantia en canviar la data d'ocurrència del sinistre
            FOR j IN (SELECT g1.cgarant
                        FROM garanseg g1,
                             garanseg g2
                       WHERE g1.sseguro = vsseguro
                         AND pfsinact BETWEEN g1.finiefe AND
                             NVL(g1.ffinefe,
                                 TO_DATE('31/12/9999', 'dd/mm/yyyy'))
                         AND g1.nmovimi =
                             (SELECT MAX(nmovimi)
                                FROM garanseg
                               WHERE sseguro = g1.sseguro
                                 AND cgarant = g1.cgarant
                                 AND nriesgo = g1.nriesgo
                                 AND pfsinact BETWEEN finiefe AND
                                     NVL(ffinefe,
                                         TO_DATE('31/12/9999', 'dd/mm/yyyy')))
                         AND g2.sseguro = vsseguro
                         AND vfsinant BETWEEN g2.finiefe AND
                             NVL(g2.ffinefe,
                                 TO_DATE('31/12/9999', 'dd/mm/yyyy'))
                         AND g2.nmovimi =
                             (SELECT MAX(nmovimi)
                                FROM garanseg
                               WHERE sseguro = g2.sseguro
                                 AND cgarant = g2.cgarant
                                 AND nriesgo = g2.nriesgo
                                 AND vfsinant BETWEEN finiefe AND
                                     NVL(ffinefe,
                                         TO_DATE('31/12/9999', 'dd/mm/yyyy')))
                         AND g1.cgarant = g2.cgarant
                         AND g1.nriesgo = g2.nriesgo
                         AND g1.sseguro = g2.sseguro
                         AND NVL(g1.icapital, 0) != NVL(g2.icapital, 0)
                            -- el capital varia entre les dues dates d'ocurrència
                         AND g1.cgarant = g2.cgarant
                         AND g1.cgarant = i.cgarant
                         AND g2.cgarant = i.cgarant)
            LOOP
               BEGIN
                  vpasexec := 20;
                  -- A partir d'aqui, composem un missatge que informi de quines garanties han variat capital
                  vnresult := f_desgarantia(i.cgarant, vcidioma, vtgarant);

                  IF vnresult != 0
                  THEN
                     -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
                     -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9902067, vpasexec,vparam);
                     RETURN 9902067;
                  ELSE
                     vpasexec         := 21;
                     vtlistagarantias := SUBSTR(vtlistagarantias ||
                                                vtgarant || ', ',
                                                1,
                                                500);
                     -- "Mort, Mort en Accident,..."
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     terror := 'i.cgarant = ' || i.cgarant ||
                               ' - j.cgarant = ' || j.cgarant || ': ';
                     RAISE;
               END;
            END LOOP;
         END;
      END LOOP;

      IF vtlistagarantias IS NOT NULL
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         --         vpasexec := 22;
         terror := f_axis_literales(9902069, f_usu_idioma);
         -- 'La/Les garantia/ies: #1han canviat el capital'
         terror := REPLACE(terror, '#1', vtlistagarantias);
         --         vpasexec := 23;
         --         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, vterror);
         --         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 5, 9902068, vterror);
         RETURN 9902069;
      END IF;

      ---------------------------------------------------------------------------------------------------------------------
      -- 3 Comprovem si el canvi en la data d'ocurrència comporta l'aparició com a vigents de garanties que no ho estaven
      -- en l'actual data de d'ocurrència i que estan afectades per la causa-motiu del sinistre
      ---------------------------------------------------------------------------------------------------------------------
      vpasexec         := 24;
      terror           := NULL;
      vtlistagarantias := NULL;

      -- 3.1) Recuperem les garanties afectades per la causa-motiu del siniestre
      FOR i IN (SELECT DISTINCT sgcm.cgarant
                  FROM sin_siniestro        si,
                       tramitacionsini      ts,
                       sin_causa_motivo     scm,
                       sin_gar_causa_motivo sgcm,
                       seguros              s
                 WHERE s.sseguro = si.sseguro
                   AND si.nsinies = pnsinies
                   AND si.nsinies = ts.nsinies
                      --                            AND pac_siniestros.f_get_cesttra(si.nsinies, ts.ntramit) NOT IN
                      --                                                                                         (2, 3)
                   AND si.ccausin = scm.ccausin
                   AND si.cmotsin = scm.cmotsin
                   AND scm.scaumot = sgcm.scaumot
                   AND s.sproduc = sgcm.sproduc
                   AND s.cactivi = sgcm.cactivi
                   AND ts.ctramit = sgcm.ctramit
                 ORDER BY sgcm.cgarant)
      LOOP
         DECLARE
            vtgarant garangen.tgarant%TYPE;
            vnresult NUMBER;
         BEGIN
            vpasexec := 25;

            -- 3.2) De l'anterior llista de garanties, recuperem aquelles contratades i que no estant vigents en la data d'ocurrència
            -- del sinistre passarien a estar-ho amb la nova data.
            FOR k IN (SELECT g1.cgarant
                        FROM garanseg g1
                       WHERE g1.sseguro = vsseguro
                            -- Garanties vigents en la nova data d'ocurrència
                         AND pfsinact BETWEEN g1.finiefe AND
                             NVL(g1.ffinefe,
                                 TO_DATE('31/12/9999', 'dd/mm/yyyy'))
                         AND g1.nmovimi =
                             (SELECT MAX(nmovimi)
                                FROM garanseg
                               WHERE sseguro = g1.sseguro
                                 AND cgarant = g1.cgarant
                                 AND nriesgo = g1.nriesgo
                                 AND pfsinact BETWEEN finiefe AND
                                     NVL(ffinefe,
                                         TO_DATE('31/12/9999', 'dd/mm/yyyy')))
                         AND g1.cgarant = i.cgarant
                            -- Les garanties no estaven vigents en l'anterior data d'ocurrència
                         AND NOT EXISTS
                       (SELECT g2.cgarant
                                FROM garanseg g2
                               WHERE g1.sseguro = vsseguro
                                 AND vfsinant BETWEEN g2.finiefe AND
                                     NVL(g2.ffinefe,
                                         TO_DATE('31/12/9999', 'dd/mm/yyyy'))
                                 AND g2.nmovimi =
                                     (SELECT MAX(nmovimi)
                                        FROM garanseg g2
                                       WHERE g2.sseguro = g1.sseguro
                                         AND g2.cgarant = g1.cgarant
                                         AND g2.nriesgo = g1.nriesgo
                                         AND vfsinant BETWEEN g2.finiefe AND
                                             NVL(g2.ffinefe,
                                                 TO_DATE('31/12/9999',
                                                         'dd/mm/yyyy')))
                                 AND g1.cgarant = g2.cgarant
                                 AND g1.nriesgo = g2.nriesgo
                                 AND g1.sseguro = g2.sseguro
                                 AND g2.cgarant = g1.cgarant))
            LOOP
               BEGIN
                  vpasexec := 26;
                  -- A partir d'aqui, composem un missatge que informi de quines garanties passen a estar vigents en la nova data
                  vnresult := f_desgarantia(i.cgarant, vcidioma, vtgarant);

                  IF vnresult != 0
                  THEN
                     -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
                     -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9902067, vpasexec,vparam);
                     RETURN 9902067;
                  ELSE
                     vpasexec         := 27;
                     vtlistagarantias := SUBSTR(vtlistagarantias ||
                                                vtgarant || ', ',
                                                1,
                                                500);
                     -- "Mort, Mort en Accident,..."
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     terror := 'i.cgarant = ' || i.cgarant ||
                               ' - k.cgarant = ' || k.cgarant || ': ';
                     RAISE;
               END;
            END LOOP;
         END;
      END LOOP;

      IF vtlistagarantias IS NOT NULL
      THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         --         vpasexec := 28;
         terror := f_axis_literales(9902070, f_usu_idioma);
         -- 'La/Les garantia/ies: #1tenen pagaments pendents i no estan contractades en la nova data d'ocurrència
         terror := REPLACE(terror, '#1', vtlistagarantias);
         --         vpasexec := 29;
         --         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, vterror);
         --         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 5, 9902070, vterror);
         RETURN 9902070;
      END IF;

      vpasexec := 30;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la utilizacion del objeto mensajes
         -- pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9902067, vpasexec, vparam, NULL,SQLCODE, SQLERRM);
         RETURN 9902067;
         -- 'Error en validar el canvi de la data d'ocurrència del sinistre'
   END f_cabecerasini2;

   -- Fin bug 18554 - 07/06/2011 - SRA

   /*************************************************************************
      FUNCTION f_valida_juzgado
         Valida datos de un juicio
         param in pnsinies  : Número siniestro
         param in pfnotiase : Fecha notificación o emplazamiento al asegurado
         param in pfrecpdem : Fecha recepción demanda
         param in pfnoticia : Fecha notificación o emplazamiento a la CIA
         param in pfcontase : Fecha contestación demanda asegurado
         param in pfcontcia : Fecha contestación demanda CIA
         param in pfaudprev : Fecha audiencia previa
         param in pfjuicio  : Fecha del juicio
         param in pntipopro : Tipo de procedimiento (VF=800065)
         param in pcresplei : Resultado del pleito (VF=800062)
         param in pnclasede : Clase de demanda (VF=800066)
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 19821 - 24/11/2011 - MDS - Validación Tramitación judicial (se añaden campos nuevos)
   *************************************************************************/
   FUNCTION f_valida_juzgado(pnsinies  IN NUMBER,
                             pfnotiase IN DATE,
                             pfrecpdem IN DATE,
                             pfnoticia IN DATE,
                             pfcontase IN DATE,
                             pfcontcia IN DATE,
                             pfaudprev IN DATE,
                             pfjuicio  IN DATE,
                             pntipopro IN NUMBER,
                             pcresplei IN NUMBER,
                             pnclasede IN NUMBER) RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'pac_validaciones_sin.f_valida_juzgado';
      vparam      VARCHAR2(2000) := 'parámetros - pctiptra: ' ||
                                    ' pnsinies : ' || pnsinies ||
                                    ' pfnotiase : ' || pfnotiase ||
                                    ' pfrecpdem : ' || pfrecpdem ||
                                    ' pfnoticia : ' || pfnoticia ||
                                    ' pfcontase : ' || pfcontase ||
                                    ' pfcontcia : ' || pfcontcia ||
                                    ' pfaudprev : ' || pfaudprev ||
                                    ' pfjuicio : ' || pfjuicio ||
                                    ' pntipopro : ' || pntipopro ||
                                    ' pcresplei : ' || pcresplei ||
                                    ' pnclasede : ' || pnclasede;
      vpasexec    NUMBER(5) := 1;
      v_fsinies   DATE;
   BEGIN
      IF (pnsinies IS NOT NULL)
      THEN
         vpasexec := 2;

         SELECT fsinies
           INTO v_fsinies
           FROM sin_siniestro
          WHERE nsinies = pnsinies;

         vpasexec := 3;

         --
         IF (pfnotiase IS NOT NULL) AND
            NOT (pfnotiase > v_fsinies)
         THEN
            RETURN 9902797;
         END IF;

         vpasexec := 4;

         --
         IF (pfnotiase IS NULL) AND
            (pfrecpdem IS NOT NULL)
         THEN
            RETURN 9902805;
         END IF;

         vpasexec := 5;

         --
         IF (pfrecpdem IS NOT NULL) AND
            NOT (pfrecpdem > v_fsinies) AND
            NOT (pfrecpdem >= pfnotiase)
         THEN
            RETURN 9902797;
         END IF;

         vpasexec := 6;

         --
         IF (pfnoticia IS NOT NULL) AND
            NOT (pfnoticia > v_fsinies)
         THEN
            RETURN 9902798;
         END IF;

         vpasexec := 7;

         --
         IF (pfcontase IS NOT NULL) AND
            NOT (pfcontase > pfrecpdem)
         THEN
            RETURN 9902799;
         END IF;

         vpasexec := 8;

         --
         IF (pfcontcia IS NOT NULL) AND
            NOT (pfcontcia > pfrecpdem)
         THEN
            RETURN 9902800;
         END IF;

         vpasexec := 9;

         --
         IF (pfaudprev IS NOT NULL) AND
            NOT (pfaudprev > pfrecpdem)
         THEN
            RETURN 9902801;
         END IF;

         vpasexec := 10;

         --
         IF (pfjuicio IS NOT NULL) AND
            NOT (pfjuicio > pfrecpdem)
         THEN
            RETURN 9902802;
         END IF;

         vpasexec := 11;

         --
         IF (pfjuicio IS NULL) AND
            (pntipopro IS NOT NULL) AND
            (pntipopro IN (4, 9))
         THEN
            RETURN 9902803;
         END IF;

         vpasexec := 12;

         IF (pcresplei IS NOT NULL) AND
            (pnclasede IS NOT NULL) AND
            (pcresplei = 6 AND pnclasede = 4)
         THEN
            RETURN 9902804;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001449; --Error validar tramitación siniestro
   END f_valida_juzgado;

   /*************************************************************************
      FUNCTION f_movtramte
         Valida el moviment de tramitació
         param in pnsinies  : número de sinistre
         param in pNTRAMTE  : número de tramitació
         param in pCESTTTE  : estat tramitació
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0022108 - 19/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_movtramte(pnsinies IN VARCHAR2,
                        pntramte IN NUMBER,
                        pcesttte IN NUMBER) RETURN NUMBER IS
      vobjectname  VARCHAR2(500) := 'pac_validaciones_sin.f_movtramte';
      vparam       VARCHAR2(500) := 'parámetros - pnsinies: ' || pnsinies ||
                                    ' pNTRAMTE:' || pntramte ||
                                    ' pCESTTTE:' || pcesttte;
      vpasexec     NUMBER(5) := 1;
      vcesttte_ant NUMBER(2);
      v_cempres    NUMBER;
      v_cnivper    NUMBER;
      v_dummy      NUMBER := 0;
      vnerror      NUMBER := 0;
   BEGIN
      vpasexec := 100;

      --Comprovació dels parámetres d'entrada
      IF pnsinies IS NULL OR
         pntramte IS NULL
      THEN
         RETURN 9001392;
      END IF;

      vpasexec := 110;

      IF pcesttte IS NULL OR
         pcesttte < 0
      THEN
         RETURN 9000927; --Campo Código Estado Tramitación obligatorio
      END IF;

      BEGIN
         vpasexec := 120;

         SELECT cesttte
           INTO vcesttte_ant
           FROM sin_tramite_mov
          WHERE nsinies = pnsinies
            AND ntramte = pntramte
            AND nmovtte = (SELECT MAX(nmovtte)
                             FROM sin_tramite_mov
                            WHERE nsinies = pnsinies
                              AND ntramte = pntramte);
      EXCEPTION
         WHEN no_data_found THEN
            --és el primer moviment de tramitació
            vcesttte_ant := NULL;
      END;

      vpasexec := 130;

      SELECT s.cempres
        INTO v_cempres
        FROM sin_siniestro ss,
             seguros       s
       WHERE ss.sseguro = s.sseguro
         AND ss.nsinies = pnsinies;

      BEGIN
         vpasexec := 140;

         SELECT DISTINCT cnivper
           INTO v_cnivper
           FROM sin_codtramitador sc
          WHERE cusuari = f_user
            AND cempres = v_cempres
            AND cactivo = 1
            AND ctiptramit = 3; -- Bug 33298 - 04/11/2014 - JTT
      EXCEPTION
         WHEN no_data_found THEN
            v_cnivper := NULL;
         WHEN too_many_rows THEN
            v_cnivper := NULL;
      END;

      IF v_cnivper IS NULL
      THEN
         BEGIN
            vpasexec := 150;

            SELECT MIN(cnivper)
              INTO v_cnivper
              FROM sin_codtramitador sc
             WHERE cusuari =
                   pac_parametros.f_parempresa_t(v_cempres, 'USER_BBDD')
               AND cempres = v_cempres
               AND cactivo = 1
               AND ctiptramit = 3; -- Bug 33298 - 04/11/2014 - JTT
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 9902263;
         END;
      END IF;

      vpasexec := 160;

      SELECT COUNT('1')
        INTO v_dummy
        FROM sin_transiciones st
       WHERE st.cempres = v_cempres
         AND st.ctiptra = 3
         AND st.cnivper = v_cnivper
         AND (vcesttte_ant IS NULL OR st.cestant = vcesttte_ant)
         AND (pcesttte IS NULL OR st.cestsig = pcesttte);

      IF v_dummy = 0
      THEN
         RETURN 9902264;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001443; --Error validar moviment tramitació
   END f_movtramte;

   /*************************************************************************
      FUNCTION f_repetido
         Comprueba si hay otro siniestro con la misma causa y fecha
         param in psseguro  : clave seguros
         param in pfsinies  : fecha ourrencia
         param in pccausa   : causa siniestro
         param in pnsinies  : número de siniestro
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
        0024491: MDP_S001-SIN - Control siniestros duplicados : ASN:31/10/2012
   *************************************************************************/
   FUNCTION f_repetido(psseguro IN NUMBER,
                       pfsinies IN DATE,
                       pccausin IN NUMBER,
                       pnsinies IN VARCHAR2) RETURN NUMBER IS
      d_abierto    DATE;
      d_cerrado    DATE;
      v_objectname VARCHAR2(100) := 'PAC_VALIDACIONES_SIN.f_repetido';
      v_param      VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                    ' pfsinies:' || pfsinies ||
                                    ' pccausin=' || pccausin ||
                                    ' pnsinies:' || pnsinies;
      v_pasexec    NUMBER;
      v_sseguro    NUMBER;
      v_fsinies    DATE;
      v_ccausin    NUMBER;
      v_cuantos    NUMBER;
      v_sproduc    NUMBER; --0030882/0173358:NSS:25/04/2014
   BEGIN
      v_pasexec := 1;

      IF psseguro IS NOT NULL AND
         pfsinies IS NOT NULL AND
         pccausin IS NOT NULL
      THEN
         v_sseguro := psseguro;
         v_fsinies := pfsinies;
         v_ccausin := pccausin;
      ELSIF psseguro IS NULL AND
            pfsinies IS NULL AND
            pccausin IS NULL
      THEN
         SELECT si.sseguro,
                fsinies,
                ccausin,
                sproduc --0030882/0173358:NSS:25/04/2014
           INTO v_sseguro,
                v_fsinies,
                v_ccausin,
                v_sproduc --0030882/0173358:NSS:25/04/2014
           FROM sin_siniestro si,
                seguros       s --0030882/0173358:NSS:25/04/2014
          WHERE nsinies = pnsinies
            AND si.sseguro = s.sseguro;
      END IF;

      v_pasexec := 2;

      SELECT COUNT(*)
        INTO v_cuantos
        FROM sin_siniestro    si,
             sin_movsiniestro sm --BUG 28049:NSS:06/09/2013
       WHERE sseguro = v_sseguro
         AND ccausin = v_ccausin
         AND TRUNC(fsinies) = TRUNC(v_fsinies)
            -- Bug 29224 - 14/03/2014 - JTT
         AND si.nsinies <> NVL(pnsinies, '**')
         AND sm.nsinies = si.nsinies
         AND sm.nmovsin = (SELECT MAX(nmovsin) --BUG 28049:NSS:06/09/2013
                             FROM sin_movsiniestro sm2 --BUG 28049:NSS:06/09/2013
                            WHERE sm2.nsinies = sm.nsinies) --BUG 28049:NSS:06/09/2013
         AND sm.cestsin NOT IN (2, 3); --BUG 28049:NSS:06/09/2013;

      IF NVL(f_parproductos_v(v_sproduc, 'SIN_VALCAUSAUNICPROD'), -1) <> 0
      --0030882/0173358:NSS:25/04/2014
      THEN
         IF v_cuantos > 0
         THEN
            RETURN 9902112;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_objectname,
                     v_pasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001380; --Error validar siniestro
   END f_repetido;

   /*************************************************************************
      FUNCTION f_repetido_ctipsin
         Comprueba si hay otro siniestro con el mismo tipo de causa
         param in psseguro  : clave seguros
         param in pfsinies  : fecha ourrencia
         param in pccausa   : causa siniestro
         param in pnsinies  : número de siniestro
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
        0024491: MDP_S001-SIN - Control siniestros duplicados : ASN:31/10/2012
   *************************************************************************/
   FUNCTION f_repetido_ctipsin(psseguro IN NUMBER,
                               pfsinies IN DATE,
                               pccausin IN NUMBER,
                               pnsinies IN VARCHAR2) RETURN NUMBER IS
      d_abierto    DATE;
      d_cerrado    DATE;
      v_objectname VARCHAR2(100) := 'PAC_VALIDACIONES_SIN.f_repetido_ctipsin';
      v_param      VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                    ' pfsinies:' || pfsinies ||
                                    ' pccausin=' || pccausin ||
                                    ' pnsinies:' || pnsinies;
      v_pasexec    NUMBER;
      v_sseguro    NUMBER;
      --v_fsinies      DATE;
      v_ccausin NUMBER;
      v_cuantos NUMBER;
      v_ctipsin sin_causa_motivo.ctipsin%TYPE;
   BEGIN
      v_pasexec := 1;

      -- No tenemos en cuenta la fecha pfsinies
      IF psseguro IS NOT NULL AND
         pccausin IS NOT NULL
      THEN
         v_sseguro := psseguro;
         v_ccausin := pccausin;
      ELSIF psseguro IS NULL AND
            pccausin IS NULL
      THEN
         SELECT sseguro,
                ccausin
           INTO v_sseguro,
                v_ccausin
           FROM sin_siniestro
          WHERE nsinies = pnsinies;
      END IF;

      v_pasexec := 2;

      SELECT MAX(ctipsin)
        INTO v_ctipsin
        FROM sin_causa_motivo
       WHERE ccausin = v_ccausin;

      v_pasexec := 3;

      -- Buscar en las causas del mismo tipo de siniestro
      SELECT COUNT(*)
        INTO v_cuantos
        FROM sin_siniestro
       WHERE sseguro = v_sseguro
         AND ccausin IN
             (SELECT ccausin FROM sin_causa_motivo WHERE ctipsin = v_ctipsin)
         AND nsinies <> NVL(pnsinies, '**');

      IF v_cuantos > 0
      THEN
         -- Siniestro duplicado con tipo de causa de siniestro, en la misma póliza
         RETURN 9905973;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_objectname,
                     v_pasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001380; --Error validar siniestro
   END f_repetido_ctipsin;

   -- Bug 0027487 - 25/11/2013 - NSS
   /*************************************************************************
      FUNCTION f_valida_declarante
         Comprueba si el declarante del siniestro es el adecuado para el tipo de garantía
         param in psseguro  : clave seguros
         param in pctipdec : tipo de declarante
         param in pcgarant   : código garantia seleccionada
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_valida_declarante(psseguro IN NUMBER,
                                pctipdec IN NUMBER,
                                pcgarant IN NUMBER) RETURN NUMBER IS
      v_objectname VARCHAR2(100) := 'PAC_VALIDACIONES_SIN.f_valida_declarante';
      v_param      VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                    'pctipdec:' || pctipdec || ' pcgarant:' ||
                                    pcgarant;
      v_pasexec    NUMBER;
      v_cramo      NUMBER;
      v_cmodali    NUMBER;
      v_ctipseg    NUMBER;
      v_ccolect    NUMBER;
      v_cactivi    NUMBER;
   BEGIN
      v_pasexec := 1;

      IF NVL(pctipdec, 0) = 1
      THEN
         -- si el declarante es el asegurado
         SELECT seg.cramo,
                seg.cmodali,
                seg.ctipseg,
                seg.ccolect,
                seg.cactivi
           INTO v_cramo,
                v_cmodali,
                v_ctipseg,
                v_ccolect,
                v_cactivi
           FROM seguros seg
          WHERE seg.sseguro = psseguro;

         v_pasexec := 2;

         IF NVL(f_pargaranpro_v(v_cramo,
                                v_cmodali,
                                v_ctipseg,
                                v_ccolect,
                                v_cactivi,
                                pcgarant,
                                'MUERTE'),
                0) = 1 -- si es garantia de muerte
         THEN
            v_pasexec := 3;
            RETURN 9905837; -- Tipo declarante erroneo
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_objectname,
                     v_pasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001380; --Error validar siniestro
   END f_valida_declarante;

   /*************************************************************************
      FUNCTION f_valida_garantia
         Comprueba validaciones propias de la garantia seleccionada
         param in psseguro  : clave seguros
         param in pcgarant   : código garantia seleccionada
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0024708/162026- 31/12/2013 - NSS
      -- Bug 35654 - 13/05/2015 - JDS: Se modifica la funcion para que realice todas las validaciones
      -- necesarias sobre las fechas de inicio y fin de las garantias de 'BAJA'
   *************************************************************************/
   FUNCTION f_valida_garantia(psseguro IN NUMBER,
                              pnriesgo IN NUMBER,
                              pcgarant IN NUMBER,
                              pndias   IN NUMBER,
                              pfsinies IN DATE,
                              pfresini IN DATE,
                              pfresfin IN DATE,
                              porigen  IN VARCHAR2,
                              pterror  OUT tab_error.terror%TYPE)
      RETURN NUMBER IS
      v_objectname    VARCHAR2(100) := 'PAC_VALIDACIONES_SIN.f_valida_garantia';
      v_param         VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                       ' pcgarant:' || pcgarant ||
                                       ' pnriesgo:' || pnriesgo ||
                                       ' pndias:' || pndias || ' pfsinies:' ||
                                       pfsinies || ' pfresini:' || pfresini ||
                                       ' pfresfin:' || pfresfin ||
                                       ' PORIGEN:' || porigen;
      v_pasexec       NUMBER;
      v_cramo         NUMBER;
      v_cmodali       NUMBER;
      v_ctipseg       NUMBER;
      v_ccolect       NUMBER;
      v_cactivi       NUMBER;
      v_eventos       NUMBER := 0;
      v_tgarant       VARCHAR2(120);
      v_param_eventos NUMBER; -- javendano 25/01/2016 bug 39225
   BEGIN
      v_pasexec := 1;

      SELECT seg.cramo,
             seg.cmodali,
             seg.ctipseg,
             seg.ccolect,
             seg.cactivi
        INTO v_cramo,
             v_cmodali,
             v_ctipseg,
             v_ccolect,
             v_cactivi
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      v_pasexec := 2;

      IF NVL(f_pargaranpro_v(v_cramo,
                             v_cmodali,
                             v_ctipseg,
                             v_ccolect,
                             v_cactivi,
                             pcgarant,
                             'VAL_GAR_ALTA_SIN'),
             0) = 1 -- si es garantia de validacion
      THEN
         v_pasexec := 3;

         IF NVL(f_pargaranpro_v(v_cramo,
                                v_cmodali,
                                v_ctipseg,
                                v_ccolect,
                                v_cactivi,
                                pcgarant,
                                'BAJA'),
                0) = 1
         THEN
            IF TRUNC(pfresini) IS NULL
            THEN
               RETURN 9901215; -- Fecha inicio y fin obligatoria
            END IF;

            IF pfresfin IS NULL
            THEN
               RETURN 9001419; --Data Fi obligatoria
            ELSIF TRUNC(pfresfin) < TRUNC(pfresini)
            THEN
               RETURN 9001418;
               --La Data Fi no pot ser inferior a la Data Inici
            END IF;

            v_pasexec := 4;

            IF TRUNC(pfresini) > TRUNC(pfresfin)
            THEN
               RETURN 110361;
               -- fecha de inicio no puede ser posterior a la fecha inicial
            END IF;

            v_pasexec := 5;

            IF TRUNC(pfresini) < TRUNC(pfsinies)
            THEN
               RETURN 9906220;
               -- Fecha de inicio no puede ser anterior a la fecha de ocurrencia
            END IF;

            v_pasexec := 6;

            IF (TRUNC(pfresini) > TRUNC(f_sysdate))
            THEN
               RETURN 9908017;
               -- Fecha de inicio no puede se superior a la fecha del dia
            END IF;

            v_pasexec := 7;

            IF (TRUNC(pfresfin) > TRUNC(f_sysdate))
            THEN
               RETURN 9908016;
               -- Fecha final no puede ser superior a la fecha del dia
            END IF;
         END IF;

         v_pasexec := 8;

         SELECT tgarant
           INTO v_tgarant
           FROM garangen
          WHERE cgarant = pcgarant
            AND cidioma = f_usu_idioma;

         v_pasexec := 10;
         --bug 39225 javendano 25/01/2016
         v_param_eventos := NVL(f_pargaranpro_v(v_cramo,
                                                v_cmodali,
                                                v_ctipseg,
                                                v_ccolect,
                                                v_cactivi,
                                                pcgarant,
                                                'SIN_BAJA_EVENTOS'),
                                9999);

         IF v_param_eventos <> -1
         THEN
            --Validacion propia para garantia de baja 409
            -- Bug 35654 - 23/04/2015 - JTT: Contamos el numero de siniestros afectados por la garantia dentro del mismo año
            SELECT COUNT(DISTINCT r.nsinies)
              INTO v_eventos
              FROM sin_tramita_reserva r,
                   sin_siniestro       si,
                   sin_movsiniestro    ms
             WHERE si.sseguro = psseguro
               AND si.nriesgo = pnriesgo
               AND r.nsinies = si.nsinies
               AND r.cgarant = pcgarant
               AND TO_CHAR(r.fresini, 'yyyy') = TO_CHAR(pfresini, 'yyyy')
               AND ms.nsinies = si.nsinies
               AND ms.nmovsin =
                   (SELECT MAX(nmovsin)
                      FROM sin_movsiniestro a
                     WHERE a.nsinies = ms.nsinies)
               AND ms.cestsin NOT IN (2, 3, 5);

            v_pasexec := 11;

            -- El nombre de pantalla 'axissin032_previo' identifica la llamada que se produce para validar los datos antes de
            -- grabar la cabecera del siniestro en BDD por este motivo inclementamos en 1 el numero de siniestros (eventos).
            IF (porigen IN ('axissin032_previo'))
            THEN
               v_eventos := v_eventos + 1;
            END IF;

            --IF    v_eventos > 4
            IF v_eventos > v_param_eventos -- javendano bug 39225
            THEN
               pterror := f_axis_literales(9906391, f_usu_idioma);
               pterror := REPLACE(pterror, '#1#', v_tgarant);
               RETURN 9906391;
               -- Se ha superado el nº de eventos màximos anuales para esta garantía
            END IF;
         END IF;

         --fin bug 39225 javendano 25/01/2016
         v_pasexec := 12;

         -- Fi Bug 35654 - 23/04/2015
         --IF pndias > 45 -- javendano bug 39225
         IF pndias > NVL(f_pargaranpro_v(v_cramo,
                                         v_cmodali,
                                         v_ctipseg,
                                         v_ccolect,
                                         v_cactivi,
                                         pcgarant,
                                         'SIN_BAJA_DIAS'),
                         9999)
         THEN
            pterror := f_axis_literales(9906392, f_usu_idioma);
            pterror := REPLACE(pterror, '#1#', v_tgarant);
            RETURN 9906392;
            -- Se ha superado el nº de días màximos por evento para esta garantía
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_objectname,
                     v_pasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9001380; --Error validar siniestro
   END f_valida_garantia;

   /*************************************************************************
      FUNCTION f_get_cartera_pendiente
         Consulta si hay recibos pendientes de un seguro / riesgo
         param in psseguro  : clave seguros
         param in pnriesgo  : clave riesto
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 028830 - 28/01/2014 - JTT
   *************************************************************************/
   FUNCTION f_get_cartera_pendiente(psseguro IN seguros.sseguro%TYPE,
                                    pnriesgo IN sin_siniestro.nriesgo%TYPE)
      RETURN NUMBER IS
      v_object  VARCHAR2(200) := 'PAC_SINIESTROS.f_get_cartera_pendiente';
      v_param   VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                 ' pnriesgo:' || pnriesgo;
      v_pasexec NUMBER := 1;
      v_count   NUMBER := 0;
   BEGIN
      -- Comprovamos si hay recibos pendientes
      SELECT COUNT(*)
        INTO v_count
        FROM recibos     r,
             movrecibo   m,
             vdetrecibos v
       WHERE m.nrecibo = r.nrecibo
         AND r.sseguro = psseguro
         AND NVL(r.nriesgo, 1) = pnriesgo
         AND m.cestrec = 0
         AND m.smovrec = (SELECT MAX(smovrec)
                            FROM movrecibo m1
                           WHERE m1.nrecibo = m.nrecibo)
         AND v.nrecibo = r.nrecibo
         AND r.ctiprec NOT IN (9, 13, 15);

      RETURN v_count;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_get_cartera_pendiente;

   /*************************************************************************
      FUNCTION f_valida_ult_tra
         Comprueba si es la última tramitacion abierta del siniestro
         param in pnsinies  : códi sinistre
         param in pntramit   : Número de tramitació
         param in pcidioma   : Idioma
         param out pntramit   : Literal validacion
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0029989/165377- 13/02/2014 - NSS
   *************************************************************************/
   FUNCTION f_valida_ult_tra(pnsinies IN VARCHAR2,
                             pntramit IN NUMBER,
                             pcidioma IN NUMBER,
                             ptlitera OUT VARCHAR2) RETURN NUMBER IS
      vpasexec  NUMBER := 1;
      vparam    VARCHAR2(500);
      v_abierto NUMBER(1) := 0;

      CURSOR c1 IS
         SELECT a.ntramit,
                a.ntramte,
                b.nmovtra,
                b.cesttra
           FROM sin_tramitacion        a,
                sin_tramita_movimiento b
          WHERE a.nsinies = pnsinies
            AND a.ntramit <> pntramit
            AND b.nsinies = a.nsinies
            AND b.ntramit = a.ntramit
            AND b.nmovtra = (SELECT MAX(b2.nmovtra)
                               FROM sin_tramita_movimiento b2
                              WHERE b2.nsinies = b.nsinies
                                AND b2.ntramit = b.ntramit);
   BEGIN
      FOR f1 IN c1
      LOOP
         IF f1.cesttra IN (0, 4)
         THEN
            v_abierto := 1;
         END IF;
      END LOOP;

      IF v_abierto = 0
      THEN
         ptlitera := f_axis_literales(9906494, pcidioma);
         RETURN 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     'pac_validaciones_sin.f_valida_ult_tra',
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1;
   END f_valida_ult_tra;

   /*************************************************************************
      FUNCTION f_val_aseg_innominado
         Comprueba validaciones propias del asegurado innominado
         param in psperson  : numero persona asegurado innominado
         param out pmensaje : mensaje de validacion
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 0030882/171926- 04/04/2014 - NSS
   *************************************************************************/
   FUNCTION f_val_aseg_innominado(psperson IN NUMBER,
                                  pmensaje OUT VARCHAR2) RETURN NUMBER IS
      v_object  VARCHAR2(200) := 'PAC_VALIDACIONES_SIN.f_val_aseg_innominado';
      v_param   VARCHAR2(500) := 'parametros - psperson:' || psperson;
      v_pasexec NUMBER := 1;
      v_count   NUMBER := 0;
      vcidioma  NUMBER;
   BEGIN
      RETURN 0;
      -- 23/07/2014 - 29224 - JTT: Comentamos toda la funcion, devuelve 0
      /*
      -- Comprovamos si se encuentra como asegurado innominado en otro siniestro
      SELECT COUNT(*)
        INTO v_count
        FROM sin_tramita_personasrel p, sin_movsiniestro m
       WHERE sperson = psperson
         AND ctiprel = 4
         AND p.nsinies = m.nsinies
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro m2
                           WHERE m2.nsinies = m.nsinies)
         AND m.cestsin IN(0, 1, 4);

      vcidioma := f_usu_idioma;

      IF v_count > 0 THEN
         pmensaje := f_axis_literales(9906705, vcidioma);
         RETURN 9906705;
      END IF;

      RETURN 0;
      */
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_val_aseg_innominado;

   /*************************************************************************
      FUNCTION f_repetido_garantia
         Comprueba validaciones propias del asegurado innominado
         param in psseguro  : codigo seguro
         param in pcgarant  : codigo garantia
         param out pmensaje : mensaje de validacion
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
      -- Bug 30935- 09/04/2014 - NSS
   *************************************************************************/
   FUNCTION f_repetido_garantia(psseguro IN NUMBER,
                                pcgarant IN NUMBER,
                                ptgarant IN VARCHAR2,
                                pterror  OUT tab_error.terror%TYPE)
      RETURN NUMBER IS
      v_object  VARCHAR2(200) := 'PAC_VALIDACIONES_SIN.f_repetido_garantia';
      v_param   VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                 ' pcgarant:' || pcgarant || ' ptgarant:' ||
                                 ptgarant;
      v_pasexec NUMBER := 1;
      v_count   NUMBER := 0;
      vcidioma  NUMBER;
   BEGIN
      -- Comprovamos si se encuentra como asegurado innominado en otro siniestro
      SELECT COUNT(*)
        INTO v_count
        FROM sin_tramita_reserva r,
             sin_siniestro       si,
             sin_movsiniestro    m
       WHERE r.nsinies = si.nsinies
         AND r.cgarant = pcgarant
         AND r.nsinies = m.nsinies
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro m2
                           WHERE m2.nsinies = m.nsinies)
         AND si.sseguro = psseguro
         AND m.cestsin IN (0, 1, 4);

      vcidioma := f_usu_idioma;

      IF v_count > 0
      THEN
         pterror := f_axis_literales(9906710, f_usu_idioma);
         pterror := REPLACE(pterror, '#1', ptgarant);
         RETURN 9906710;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     v_pasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_repetido_garantia;

   /*************************************************************************
      FUNCTION f_validar_documento_cierre
         Validamos que solo hay un documento de Cierre por siniestro
         param in nsinies  : numero de siniestro
         param in ntramit  : numero de tramitacion
         param in pcdocume : codigo de documento
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validar_documento_cierre(pnsinies IN sin_siniestro.nsinies%TYPE,
                                       pntramit IN sin_tramitacion.ntramit%TYPE,
                                       pcdocume IN sin_tramita_documento.cdocume%TYPE)
      RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'PAC_VALIDACIONES_SIN.f_validar_documento_cierre';
      vparam      VARCHAR2(500) := ' pnsinies = ' || pnsinies ||
                                   ' pntramit = ' || pntramit ||
                                   ' pcdocume = ' || pcdocume;
      vpasexec    NUMBER := 1;
      vnumerr     NUMBER := 0;
      vcount      NUMBER;
   BEGIN
      IF pnsinies IS NULL OR
         pntramit IS NULL OR
         pcdocume IS NULL
      THEN
         vnumerr := 9000505;
         RAISE e_error;
      END IF;

      -- Validamos que no existe otro documento de tipo cierre (cdocume = 521) en todas las tramitaciones.
      SELECT COUNT(1)
        INTO vcount
        FROM sin_tramita_documento
       WHERE nsinies = pnsinies
         AND cdocume = 521;

      IF vcount > 0
      THEN
         RETURN 9907595;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     ' Error = ' || vnumerr || ' -  ' ||
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_validar_documento_cierre;

   /*************************************************************************
      FUNCTION f_validar_fecha_formalizacion
         Validamos que la fecha de recepcion ha sido informada en el documento de Cierre (521)
         param in nsinies  : numero de siniestro
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_validar_fecha_formalizacion(pnsinies IN sin_siniestro.nsinies%TYPE)
      RETURN NUMBER IS
      vobjectname VARCHAR2(500) := 'PAC_VALIDACIONES_SIN.f_validar_fecha_formalizacion';
      vparam      VARCHAR2(500) := ' pnsinies = ' || pnsinies;
      vpasexec    NUMBER := 1;
      vnumerr     NUMBER := 0;
      vcount      NUMBER;
   BEGIN
      IF pnsinies IS NULL
      THEN
         vnumerr := 9000505;
         RAISE e_error;
      END IF;

      SELECT COUNT(1)
        INTO vcount
        FROM sin_tramita_documento
       WHERE nsinies = pnsinies
         AND cdocume = 521
         AND frecibe IS NULL;

      IF vcount > 0
      THEN
         RETURN 9907597;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_error THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     ' Error = ' || vnumerr || ' -  ' ||
                     f_axis_literales(vnumerr));
         RETURN vnumerr;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobjectname,
                     vpasexec,
                     vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 1000455;
   END f_validar_fecha_formalizacion;
   /*************************************************************************
   FUNCTION f_pago_sol_sini
         Valida pagos de solidaridad en siniestros ingresando tabla con los valores 
         respectivos
         param in psseguro  : codigo seguro
         param in psidepag  : codigo sidepag
         param in pnsinies  : codigo nsinies
         param out pmensaje : mensaje de validacion
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
    -- Bug  IAXIS - 4727 - 09/04/2014 - AABC
   *************************************************************************/
   FUNCTION f_pago_sol_sini(psseguro  IN  seguros.sseguro%TYPE,
                            psidepag  IN  sin_tramita_pago.sidepag%TYPE,
                            pnsinies  IN  sin_tramita_pago.nsinies%TYPE,
                            pnpagtot  IN  sin_tramita_pago.isinretpag%TYPE,
                            pnmensaje OUT VARCHAR2) 
   RETURN NUMBER  IS
   --                         
   CURSOR cur_cuaseguro(psseguro seguros.sseguro%TYPE) IS
      --
      SELECT * 
        FROM coacuadro
       WHERE sseguro = psseguro
         AND ncuacoa = (SELECT MAX(ncuacoa) 
                          FROM coacuadro WHERE sseguro = psseguro);
   --                      
   CURSOR cur_coacedido(psseguro seguros.sseguro%TYPE,
                        pncuacoa coacedido.sseguro%TYPE) IS
      --                     
      SELECT * 
        FROM coacedido
       WHERE sseguro = psseguro
         AND ncuacoa = pncuacoa;
      --
      lisinret  NUMBER;
      lncuacoa  NUMBER;
      lsperson  NUMBER;
      lsperdes  NUMBER;
      lcmonres  VARCHAR2(4);
      lotrgas   NUMBER;
      lotrgasp  NUMBER;
      lipago    NUMBER;
      lipagcon  NUMBER;
      lipagcoa  NUMBER;
      --IAXIS 4555 AABC 10/12/2019
      lipagotr  NUMBER;
      licoaotr  NUMBER;
      liconotr  NUMBER;
      --IAXIS-5194 AABC 13/02/2020 Adicion de los deducibles
      lifranq   NUMBER; 
      lifranpag NUMBER;
      --IAXIS-5194 AABC 13/02/2020 Adicion de los deducibles
      --IAXIS 4555 AABC 10/12/2019
      v_object  VARCHAR2(200) := 'PAC_VALIDACIONES_SIN.f_pago_sol_sini';
      v_param   VARCHAR2(500) := 'parametros - psseguro:' || psseguro ||
                                 'psidepag:' || psidepag || ' pnsinies:' ||
                                  pnsinies;
      v_pasexec NUMBER := 1;                        
      -- 
   BEGIN
      --
      BEGIN 
         --IAXIS 4555 AABC 10/12/2019
	 --IAXIS-5194 AABC 13/02/2020 Adicion de los deducibles
         SELECT nvl(stp.isinretpag,stp.isinret),sperson,cmonres,nvl(stp.iotrosgas,0),nvl(stp.iotrosgaspag,0), nvl(stp.ifranqpag,0) , nvl(stp.ifranq,0)
           INTO lisinret,lsperdes,lcmonres,lotrgas,lotrgasp, lifranpag, lifranq
           FROM sin_tramita_pago  stp
          WHERE stp.nsinies = pnsinies
            AND stp.sidepag = psidepag; 
         --
	 --IAXIS-5194 AABC 13/02/2020 Adicion de los deducibles
         lipago   := lisinret - nvl(lifranpag,lifranq); 
         lipagotr := nvl(lotrgasp,lotrgas);  
	 --IAXIS-5194 AABC 13/02/2020 Adicion de los deducibles
         --IAXIS 4555 AABC 10/12/2019
      END;   
      --
      IF lipago = 0 THEN 
         --         
         lipago := pnpagtot;
         --
      END IF;      
      --
      IF lipago IS NOT NULL THEN
        --
      FOR x IN cur_cuaseguro (psseguro)LOOP
         --
         lipagcon := (lipago * x.ploccoa)/100;
         lncuacoa := x.ncuacoa;
	 --IAXIS 4555 AABC 10/12/2019
         IF lipagotr <> 0 THEN 
         --
            liconotr := (lipagotr * x.ploccoa)/100;
            --
         INSERT INTO SIN_SOLIDARIDAD_PAGO(TLIQUIDA,SSEGURO,NSINIES,SPERSON,SIDEPAG,CMONEDA,NSUCURSAL,IPAGO,FCONTAB)
                 VALUES                     (59,psseguro,pnsinies,lsperdes,psidepag,lcmonres,NULL,liconotr,f_sysdate); 
            --
         END IF;
         --
         INSERT INTO SIN_SOLIDARIDAD_PAGO(TLIQUIDA,SSEGURO,NSINIES,SPERSON,SIDEPAG,CMONEDA,NSUCURSAL,IPAGO,FCONTAB)
              VALUES                     (58,psseguro,pnsinies,lsperdes,psidepag,lcmonres,NULL,lipagcon,f_sysdate); 
         --IAXIS 4555 AABC 10/12/2019
      END LOOP;
      --   
      FOR y IN cur_coacedido(psseguro,lncuacoa) LOOP
         --
         BEGIN 
            --
            SELECT sperson
              INTO lsperson
              FROM companias
             WHERE ccompani = y.ccompan;
            --
         END;   
         --
         lipagcoa := (lipago * y.pcescoa)/100;
         --IAXIS 4555 AABC 10/12/2019
         IF lipagotr <> 0 THEN 
            --
            licoaotr := (lipagotr * y.pcescoa)/100;
            --
            INSERT INTO SIN_SOLIDARIDAD_PAGO(TLIQUIDA,SSEGURO,NSINIES,SPERSON,SIDEPAG,CMONEDA,NSUCURSAL,IPAGO,FCONTAB)
                 VALUES                     (96,psseguro,pnsinies,lsperson,psidepag,lcmonres,y.ccompan,licoaotr,f_sysdate); 
            --
         END IF;
         --IAXIS 4555 AABC 10/12/2019
         INSERT INTO SIN_SOLIDARIDAD_PAGO(TLIQUIDA,SSEGURO,NSINIES,SPERSON,SIDEPAG,CMONEDA,NSUCURSAL,IPAGO,FCONTAB)
              VALUES                     (95,psseguro,pnsinies,lsperson,psidepag,lcmonres,y.ccompan,lipagcoa,f_sysdate);
         --
      END LOOP;  
      --
      COMMIT;
      --
      END IF;
      --
      RETURN 0;
      --
    EXCEPTION WHEN OTHERS THEN 
      --     
      p_tab_error(f_sysdate,
                  f_user,
                  v_object,
                  v_pasexec,
                  v_param,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
     RETURN 1;  
   --
   END f_pago_sol_sini;
   --IAXIS 4727 AABC pagos de siniestros con solidaridad   
   --IAXIS 5454 AABC valor de reexpresion 
   /*************************************************************************
   FUNCTION f_sin_val_reexpr
        Estrae valor de reexpresion si es aumento o disminucion 
        param in pnsinies  : codigo siniestro
        param in pnmovres  : codigo numero de siniestro
        param in pidres    : codigo identificacion reserva 
        return             : Valor de rexpresion 
       -- Bug  IAXIS - 5454 - 08/11/2019 - AABC
   *************************************************************************/
   FUNCTION f_sin_val_reexpr(pnsinies  IN  sin_tramita_reservadet.nsinies%TYPE,
                             pnmovres  IN  sin_tramita_reservadet.nmovres%TYPE,
                             pidres    IN  sin_tramita_reservadet.idres%TYPE ) 
   RETURN NUMBER IS
   --
   l_aumento_moncia NUMBER;
   l_disminu_moncia NUMBER;
   v_object  VARCHAR2(200) := 'PAC_VALIDACIONES_SIN.f_sin_val_reexpr';
   v_param   VARCHAR2(500) := 'parametros - pnsinies:' || pnsinies ||
                                 'pnmovres:' || pnmovres || ' pidres:' ||
                                  pidres;   
   -- 
   BEGIN
      --
      BEGIN 
         --
         SELECT nvl(s.iaumenres_moncia,0) , nvl(s.idismires_moncia,0)
           INTO l_aumento_moncia , l_disminu_moncia
           FROM sin_tramita_reservadet s
          WHERE s.nsinies      =  pnsinies
            AND s.idres        =  pidres
            AND s.nmovres      =  pnmovres
            AND s.creexpresion IN (1,2)
            AND s.nmovresdet IN (SELECT MAX(s1.nmovresdet)
                                   FROM sin_tramita_reservadet s1
                                  WHERE s1.nsinies = s.nsinies
                                    AND s1.idres   = s.idres
                                    AND s1.nmovres = s.nmovres
                                    AND s1.creexpresion IN (1,2)); 
         --
      EXCEPTION WHEN OTHERS THEN 
         --
         l_aumento_moncia := 0;
         l_disminu_moncia := 0;
         --   
      END;
      --
      IF l_aumento_moncia > l_disminu_moncia THEN 
         --         
         RETURN l_aumento_moncia;
         --
      ELSIF l_disminu_moncia > l_aumento_moncia THEN
         --
         l_disminu_moncia := -1 * l_disminu_moncia;
         RETURN l_disminu_moncia;
         --
      ELSIF l_disminu_moncia = 0 AND l_aumento_moncia = 0 THEN 
         --
         RETURN 0;
         --     
      END IF; 
      --
    EXCEPTION WHEN OTHERS THEN 
      --     
      p_tab_error(f_sysdate,
                  f_user,                  
                  v_object,
                  NULL,
                  v_param,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
     RETURN 0; 
      --
   END f_sin_val_reexpr;   
   --
   /*************************************************************************
   FUNCTION f_sin_val_reexpr
        Estrae valor de reexpresion si es aumento o disminucion 
        param in pnsinies  : codigo siniestro
        param in pnmovres  : codigo numero de siniestro
        param in pidres    : codigo identificacion reserva 
        return             : Valor de rexpresion 
       -- Bug  IAXIS - 5454 - 08/11/2019 - AABC
   *************************************************************************/
   FUNCTION f_sin_val_trans(pnsinies  IN  sin_tramita_reservadet.nsinies%TYPE,
                            pnmovres  IN  sin_tramita_reservadet.nmovres%TYPE,
                            pidres    IN  sin_tramita_reservadet.idres%TYPE ) 
   RETURN NUMBER IS
   --
   l_aumento_moncia NUMBER;
   l_disminu_moncia NUMBER;
   l_liberac_moncia NUMBER;
   v_object  VARCHAR2(200) := 'PAC_VALIDACIONES_SIN.f_sin_val_trans';
   v_param   VARCHAR2(500) := 'parametros - pnsinies:' || pnsinies ||
                                 'pnmovres:' || pnmovres || ' pidres:' ||
                                  pidres;   
   -- 
   BEGIN
      --
      BEGIN 
         --
         SELECT nvl(s.iaumenres_moncia,0) ,nvl( s.idismires_moncia,0), nvl(s.iliberares_moncia,0)
           INTO l_aumento_moncia , l_disminu_moncia, l_liberac_moncia
           FROM sin_tramita_reservadet s
          WHERE s.nsinies      =  pnsinies
            AND s.idres        =  pidres
            AND s.nmovres      =  pnmovres
            AND s.creexpresion =  0
            AND s.nmovresdet IN (SELECT MAX(s1.nmovresdet)
                                   FROM sin_tramita_reservadet s1
                                  WHERE s1.nsinies = s.nsinies
                                    AND s1.idres   = s.idres
                                    AND s1.nmovres = s.nmovres
                                    AND s1.creexpresion = 0); 
         --
      EXCEPTION WHEN OTHERS THEN 
         --
         l_aumento_moncia := 0;
         l_disminu_moncia := 0;
         l_liberac_moncia := 0;
         --   
      END;
      --
      IF l_aumento_moncia > l_disminu_moncia THEN 
         --         
         RETURN l_aumento_moncia;
         --
      ELSIF l_disminu_moncia > l_aumento_moncia OR l_liberac_moncia > l_aumento_moncia THEN
         --
         l_disminu_moncia := l_disminu_moncia + l_liberac_moncia;
         RETURN l_disminu_moncia;
         --
      ELSIF l_disminu_moncia = 0 AND l_aumento_moncia = 0 AND l_liberac_moncia = 0 THEN 
         --
         RETURN 0;
         --     
      END IF; 
      --
    EXCEPTION WHEN OTHERS THEN 
      --     
      p_tab_error(f_sysdate,
                  f_user,                  
                  v_object,
                  NULL,
                  v_param,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
     RETURN 0; 
      --
   END f_sin_val_trans;
   --
      /*************************************************************************
   FUNCTION f_sin_val_reser
        Estrae valor de reexpresion si es aumento o disminucion 
        param in pnsinies  : codigo siniestro
        param in pnmovres  : codigo numero de siniestro
        param in pidres    : codigo identificacion reserva 
        return             : Valor de rexpresion 
       -- Bug  IAXIS - 5454 - 08/11/2019 - AABC
   *************************************************************************/
   FUNCTION f_sin_val_reser(pnsinies  IN  sin_tramita_reservadet.nsinies%TYPE,
                            pnmovres  IN  sin_tramita_reservadet.nmovres%TYPE,
                            pidres    IN  sin_tramita_reservadet.idres%TYPE ) 
   RETURN NUMBER IS
   --
   l_isalres_moncia NUMBER;
   v_object  VARCHAR2(200) := 'PAC_VALIDACIONES_SIN.f_sin_val_trans';
   v_param   VARCHAR2(500) := 'parametros - pnsinies:' || pnsinies ||
                                 'pnmovres:' || pnmovres || ' pidres:' ||
                                  pidres;   
   -- 
   BEGIN
      --
      BEGIN 
         --
         SELECT nvl(s.isalres_moncia,0)
           INTO l_isalres_moncia
           FROM sin_tramita_reservadet s
          WHERE s.nsinies      =  pnsinies
            AND s.idres        =  pidres
            AND s.nmovres      =  pnmovres
            AND s.creexpresion =  0
            AND s.nmovresdet IN (SELECT MAX(s1.nmovresdet)
                                   FROM sin_tramita_reservadet s1
                                  WHERE s1.nsinies = s.nsinies
                                    AND s1.idres   = s.idres
                                    AND s1.nmovres = s.nmovres
                                    AND s1.creexpresion = 0);  
         --
      EXCEPTION WHEN OTHERS THEN 
         --
         l_isalres_moncia := 0;
         --   
      END;
      --
      RETURN l_isalres_moncia; 
      --
    EXCEPTION WHEN OTHERS THEN 
      --     
      p_tab_error(f_sysdate,
                  f_user,                  
                  v_object,
                  NULL,
                  v_param,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
     RETURN 0; 
      --
   END f_sin_val_reser;
   
   
   /*************************************************************************
      FUNCTION f_val_res
         Obtenemos el valor de Reserva Actual, Contitución, Liberación, Disminución
         
         param in p_nsinies  : Número de siniestro
         param in p_nmovres  : Número de movimiento de Reserva
         param in p_idres    : Número de Identificación de Reserva
         param in p_idcol    : Número de idetificador de la columna (1)Reserva  (2)Constitución   (3)Liberación  (4)Disminución (5)Aumento
        --IAXIS 6242 Validadores Indemnización - Reservas brutas - IRDR - 08/01/2020

*************************************************************************/

FUNCTION f_val_res(p_nsinies IN NUMBER,
                   p_nmovres IN NUMBER,
                   p_idres   IN NUMBER,
                   p_idcol   IN NUMBER,
                   p_fdesde  IN DATE,
                   p_fhast   IN DATE)
    RETURN NUMBER IS 
    
    v_res          NUMBER; 
    v_object       VARCHAR2(200) := 'PAC_VALIDACIONES_SIN.f_val_res';
    v_param         VARCHAR2(500) := 'p_nsinies:' || p_nsinies || 'p_nmovres:' || p_nmovres || ' p_idres:' || p_idres;   
    vpasexec       NUMBER(5) := 0;  
 
    
     
   
 CURSOR C1 
     IS 
    SELECT SUM(Nvl(s.ireserva_moncia, 0))
         INTO v_res
         from sin_tramita_reserva s
         where s.nsinies = p_nsinies
         and s.nmovres = (Select max(nmovres) from sin_Tramita_reserva where nsinies =s.nsinies
                                            and cgarant =s.cgarant
                                            AND fmovres < p_fhast); 


     CURSOR C2 
     IS 
    SELECT sum(nvl(t.iconstres,0))
         INTO v_res
         from sin_tramita_reservadet t
         where t.nsinies = p_nsinies
          and t.nmovres = 1
          AND t.fmodifi between p_fdesde and p_fhast;   
          
          
          
 CURSOR C3
     IS     
      SELECT SUM(nvl(s.iliberares_moncia,0))
           INTO  v_res
           FROM sin_tramita_reservadet s
           WHERE s.nsinies      =  p_nsinies
           AND s.fmodifi between p_fdesde and p_fhast;
             
          
         
    CURSOR C4 
     IS     
      SELECT SUM(nvl( s.idismires_moncia,0))
           INTO v_res
           FROM sin_tramita_reservadet s
            WHERE s.nsinies      =  p_nsinies
             AND s.creexpresion =  0
             AND s.fmodifi between p_fdesde and p_fhast; 
                                                                                      
    CURSOR C5
     IS     
      SELECT SUM(nvl(s.iaumenres_moncia,0))
           INTO v_res 
           FROM sin_tramita_reservadet s
          WHERE s.nsinies      =  p_nsinies
            AND s.creexpresion =  0
            AND s.fmodifi between p_fdesde and p_fhast; 

    CURSOR C6
    IS    
    SELECT SUM(nvl(s.ireserva_moncia,0))
         INTO v_res
         from sin_tramita_reserva s
         where s.nsinies = p_nsinies
         and s.nmovres = (Select max(nmovres) from sin_Tramita_reserva where nsinies =s.nsinies
                                            and cgarant =s.cgarant
                                            and idres = s.idres
                                            AND fmovres < p_fdesde); 

BEGIN

   BEGIN  
     
      p_tab_error (f_sysdate, f_user, v_object, vpasexec, v_param, 'ERROR: vpasexec'||vpasexec );
     
     IF p_idcol = 1 
        then 
        
        OPEN C1;
        LOOP
        FETCH C1 INTO v_res;
    
        EXIT WHEN C1%NOTFOUND;
        END LOOP;

   CLOSE c1;
      
      END IF; 
      

   
     IF p_idcol = 2 
        then
      
        OPEN C2;
        LOOP
        FETCH C2 INTO v_res;
    
        EXIT WHEN C2%NOTFOUND;
        END LOOP;

   CLOSE C2;
      
      END IF;
      
 
     IF p_idcol = 3
        then
         
        OPEN C3;
        LOOP
        FETCH C3 INTO v_res ;
    
        EXIT WHEN C3%NOTFOUND;
        END LOOP;

      CLOSE C3;  
      END IF;  
      
 --     
       IF p_idcol in  (4)
        then
         
        OPEN C4;
        LOOP
        FETCH C4 INTO  v_res;
    
        EXIT WHEN C4%NOTFOUND;
        END LOOP;
      CLOSE C4;
      END IF;
--           
       IF p_idcol in (5) THEN
       
        p_tab_error (f_sysdate, f_user, v_object, vpasexec, v_param, 'ERROR: vpasexec'||vpasexec );
            
        OPEN C5;
        LOOP
        FETCH C5 INTO  v_res;
    
        EXIT WHEN C5%NOTFOUND;
        END LOOP;

        CLOSE C5;
          
      END IF;  
--

       IF p_idcol in (6) THEN

        p_tab_error (f_sysdate, f_user, v_object, vpasexec, v_param, 'ERROR: vpasexec'||vpasexec );

        OPEN C6;
        LOOP
        FETCH C6 INTO  v_res;

        EXIT WHEN C6%NOTFOUND;
        END LOOP;

        CLOSE C6;

      END IF;  

    END; 
      
          RETURN v_res;  
 EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     vpasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
                 
END f_val_res;
   
   --  
END pac_validaciones_sin;
