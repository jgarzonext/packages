--------------------------------------------------------
--  DDL for Package Body PAC_REA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "AXIS"."PAC_REA" IS
/******************************************************************************
  NAME:       pac_rea
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/07/2009    ETM            1. Created this package body.--Nuevo paquete de negocio que contiene las funciones del m?dulo de reaseguro
   2.0        13/07/2009    ETM            2. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   3.0        02/09/2009    ICV            3. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo (Se rehacen por completo las funciones)
   4.0        07/09/2009    ICV            4. 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos
   5.0        03/11/2009    ICV            5. 0011327: IAX - REA: Parametrizaci?n mantenimiento de contratos Reaseguro
   6.0        30/10/2009    ICV            6. 0011353: CEM - Parametrizaci?n mantenimiento de contratos Reaseguro
   7.0        14/05/2010    AVT            7. 0014536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                              en varias agrupaciones de producto
   8.0        04/07/2011    APD            8. 0018319: LCOL003 - Pantalla de mantenimiento del contrato de reaseguro
   9.0        20/01/2012    AVT            9. 0020994: LCOL_A002-Reaseguro: Repasar el funcionamiento del facultativo en caso de informar importe
  10.0        23/05/2012    AVT           10. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
  10.1        08/10/2012    AVT           11. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  11.0        18/01/2013    AEG           11. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
  12.0        25/06/2013    DCT           12. 0021559: LCOL999-Cambios en el Reaseguro
  13.0        02/07/2013    KBR           13. 0021559: LCOL999-Cambios en el Reaseguro (Garant?s Agrupadas)
  14.0        15/07/2013    KBR           14. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  15.0        17/07/2013    KBR           15. 0027545: El sistema no realiza la modificacion - axisrea020 mant
  16.0        23/07/2013    JDS           16. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
  17.0        31/07/2013    ETM           17. 0026444: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 150 -entidad economica de las agrupaciones (Fase3)
  18.0        23/08/2013    KBR           18. 0027911: LCOL_A004-Qtracker: 6163: Validacion campos pantalla mantenimiento cuentas reaseguro (Liquidaciones)
  19.0        05/09/2014    DCT           19. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  20.0        16/09/2013    KBR           20. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  21.0        30/09/2013    RCL           21. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  22.0        11/11/2013    SHA           22.0028083: LCOL_A004-0008945: Error en pantalla consulta de reposiciones
  23.0        14/11/2013    DCT           23  0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
  24.0        15/11/2013    JDS           24. 0028493: LCOLF3BREA-Revisi?n interfaces Liquidaci?n Reaseguro F3B
  25.0        04/12/2013    RCM           25. 0028992: (POSPG400)-Parametrizacion (Apuntes manuales)
  26.0        20/12/2013    DCT           26. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  27.0        20/12/2013    DCT           26. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  28.0        21/01/2014    JAM           27. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  29.0        14/05/2014    AGG           29. 0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
  30.0        16/07/2014    KBR           30. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  31.0        04/09/2014    KBR           31. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  32.0        10/09/2014    KBR           32. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  33.0        22/09/2014    MMM           33. 0027104: LCOLF3BREA- ID 180 FASE 3B - Cesiones Manuales
  34.0        11/05/2015    KBR           34. 0033209: LCOLF3BREA-0015176: Prueba Cesiones Manuales- Distribución de reaseguros
  35.0        19/11/2015    DCT           35. 0038692: POSPT500-POS REASEGUROS CESIÓN DE VIDA INDIVIDUAL Y COMISIONES SOBRE EXTRA PRIMAS
  36.0        02/09/2016    HRE           36. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
  37.0        12/02/2018    HRE           37. Incluir nueva validación para evitar validaciòn durante el proceso de migración.
  38.0        06/20/2019    JRR           38. IAXIS-4404: Se incluye validacion cuadro facultativo por ajuste manual de cesiones
  39.0        06/20/2019    JRR           39. IAXIS-4448: Se incluye filtro de CTRAMO = 5 para busqueda cabecera y detalle facultativo
  40.0        09/07/2019    FEPP          40. IAXIS-4615 En cesiones debe verse el movimiento del recobro en forma separada
  41.0        15/07/2019    FEPP          41. IAXIS-4611:Campo para grabar la prioridad por tramo y el limite por tramo
  42.0        26/01/2020    INFORCOL      42. Reaseguro facultativo - ajuste para deposito en prima retenida
  43.0        04/02/2020    INFORCOL      43. Reaseguro - Ajuste retencion local y retencion reasegurador
  44.0        06/02/2020    INFORCOL      44. Reaseguro - Ajuste retencion local y retencion reasegurador calculo saldo
  45.0        07/04/2020    FEPP          45. IAXIS-BUG/13135:Se hacen endosos de pólizas en dolares y euros. Y el valor de la cesión la hace con la tasa de cambio del día de la emisión de la póliza y no de la tasa del día de la emisión del endoso. 
  46.0        14/05/2020    INFORCOL      45. Reaseguro Facultativo - Deposito en prima nuevas columnas CUASEFAC - Ajuste consulta retencion local y retencion reasegurador - Recobros: Ajuste en consulta contratos del movimiento
  47.0        26/05/2020    DFRP          46. IAXIS-5361: Modificar el facultativo antes de la emisión
   ******************************************************************************/

   /*BUG 10487 - 13/07/2009 - ETM - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
      Valida que todos los campos obligatorios se hayan introducido, que no se informen campos incompatibles entre si
      y que la suma de la cesi?n a compa??as, cuando el cuadro est? completo sea siempre igual a 100%.

      PSFACULT in NUMBER
      PCESTADO in NUMBER
      PFINCUF in DATE
      PCCOMPANI in NUMBER
      PPCESION in NUMBER
      PICESFIJ in NUMBER
      PCCOMREA in NUMBER
      PPCOMISI in NUMBER
      PICOMFIG in NUMBER
      PISCONTA in NUMBER
      PPRESERV in NUMBER
      PCINTRES in NUMBER
      PINTRES in NUMBER
   *************************************************************************/
   FUNCTION f_valida_cuadro_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pfincuf IN DATE,
      pplocal IN NUMBER,
      pifacced IN NUMBER, -- IAXIS-5361 26/05/2020
      pccompani IN NUMBER,
      ppcesion IN NUMBER,
      picesfij IN NUMBER,
      pccomrea IN NUMBER,
      ppcomisi IN NUMBER,
      picomfij IN NUMBER,
      pisconta IN NUMBER,
      ppreserv IN NUMBER,
      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      ppresrea IN NUMBER,
      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      pcintres IN NUMBER,
      pintres IN NUMBER,
      pctipfac IN NUMBER,   -- 20/08/2012 AVT 22374 CUAFACUL
      pptasaxl IN NUMBER,
      pccorred IN NUMBER,   -- 20/08/2012 AVT 22374 CUACESFAC
      pcfreres IN NUMBER,
      pcresrea IN NUMBER,
      pcconrec IN NUMBER,
      pfgarpri IN DATE,
      pfgardep IN DATE,
      ppimpint IN NUMBER,   -- BUG: 25502 17-01-2013 AEG 25502
      ptidfcom IN VARCHAR2,
      psseguro IN NUMBER)   --BUG38692 19/11/2015 DCT
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vnumerr        NUMBER := 0;
      vhaydetalle    NUMBER := 0;
      vlocal         cuafacul.plocal%TYPE;
      v_cestado      cuafacul.cestado%TYPE;
      v_pcesion      cuacesfac.pcesion%TYPE;
      v_dummy        NUMBER := 0;
      v_existe_cuafac NUMBER;
      v_completar    NUMBER;
      v_cpolcia      NUMBER;
	  v_cesion       NUMBER;
      --
      -- Inicio IAXIS-5361 26/05/2020
      --
      v_pfacced      NUMBER; 
      v_ifacced      NUMBER; 
      v_ifaccedini   NUMBER;
      v_ifaccedaux   NUMBER;
      --
      -- Fin IAXIS-5361 26/05/2020
      --
   BEGIN
      --Realizamos la validación de la póliza para ver si esta retenida por facultativo. Si es así podemos completar el cuadro facultativo.
      --En caso contrario no dejaremos completar el cuadro facultativo
      SELECT COUNT(1)
        INTO v_completar
        FROM seguros s
       WHERE s.sseguro = psseguro
         AND((s.creteni IN(1, 2))
             OR(s.creteni = 0
                AND csituac IN(4, 5)))
         AND EXISTS(SELECT 1
                      FROM psucontrolseg p1
                     WHERE p1.sseguro = s.sseguro
                       AND p1.ccontrol = 526031
                       AND p1.nmovimi = (SELECT MAX(p2.nmovimi)
                                           FROM psucontrolseg p2
                                          WHERE p2.sseguro = p1.sseguro
                                            AND p2.ccontrol = p1.ccontrol
                                            AND p2.nriesgo = p1.nriesgo)
                       AND p1.nvalor = 1);
      --
      SELECT COUNT(1)
        INTO v_cpolcia
        FROM seguros
       WHERE sseguro = psseguro
         AND cpolcia IS NOT NULL;

      --ini IAXIS-4404
      SELECT COUNT(1)
        INTO v_cesion
        FROM CUAFACUL 
      WHERE SSEGURO = psseguro
         AND CESTADO = 1
         AND FFINCUF IS NULL;
      --fin IAXIS-4404
      --
      --Si no podemos completar retornamos el error de porqué
      IF v_completar = 0
         AND v_cpolcia = 0 -- poliza No migrada
			AND v_cesion = 0--IAXIS-4404
      THEN
         --9906179 --> La póliza no requiere ningún cuadro facultativo
         RETURN 9906179;
      END IF;

      SELECT COUNT(1)
        INTO vhaydetalle
        FROM cuacesfac
       WHERE sfacult = psfacult;

      -->> Validaci?n de campos
      IF (pccompani IS NULL
          AND pplocal < 100) THEN
         vnumerr := 101734;   --> Falta compa??a
         RETURN vnumerr;
      END IF;

      IF psfacult IS NULL THEN
         vnumerr := 9002121;   --Falta facultativo
         RETURN vnumerr;
      END IF;

      IF pcestado IS NULL THEN
         vnumerr := 801254;   --Estado obligatorio
         RETURN vnumerr;
      END IF;

      IF (ppcesion IS NULL
          AND picesfij IS NULL
          AND(pplocal < 100
              OR vhaydetalle > 0)) THEN
         vnumerr := 104807;   --> Se ha de introducir un porcentaje de cesi?n o un importe fijo de cesi?n
         RETURN vnumerr;
      END IF;

      -->> Validaci?n de %
      IF (ppcomisi IS NOT NULL
          AND picomfij IS NOT NULL)
         OR(pccomrea IS NOT NULL
            AND picomfij IS NOT NULL)
         OR(ppcomisi IS NOT NULL
            AND pccomrea IS NOT NULL) THEN
         vnumerr := 103814;   --> Entrar c?digo de comisi?n o importe
         RETURN vnumerr;
      END IF;

      --27545 - KBR 17/07/2013
      -->> Validaci?n pels interessos
      IF (pintres IS NOT NULL
          AND pcintres IS NOT NULL) THEN
         vnumerr := 9002241;   --> Entrar s?lo codigo de inter?s o importe de inter?s
         RETURN vnumerr;
      END IF;

      --27545 - KBR 17/07/2013 Modificamos la validaci?
      -- Validaci? de les cessions
      IF ppcesion <= 0
         AND picesfij <= 0 THEN
         vnumerr := 104807;   --> Se ha de introducir un porcentaje de cesi?n o un importe fijo de cesi?n
         RETURN vnumerr;
      ELSE
         IF ppcesion <= 0
            OR picesfij <= 0 THEN
            vnumerr := 104807;   --> Se ha de introducir un porcentaje de cesi?n o un importe fijo de cesi?n
            RETURN vnumerr;
         END IF;
      END IF;

      BEGIN
         SELECT 1
           INTO v_existe_cuafac
           FROM cuacesfac
          WHERE sfacult = psfacult
            AND ccompani = pccompani;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (ppcesion IS NOT NULL
                AND picesfij IS NOT NULL) THEN
               vnumerr := 9904135;   --> Entrar s?lo % de cesi?n o importe de cesi?n
               RETURN vnumerr;
            END IF;
      END;

      vpasexec := 2;

      IF (ppcesion > 0
          OR vhaydetalle > 0) THEN
         -- BUG : 25502 17-01-2013 AEG se agrega ppimpint
         vnumerr := pac_rea.f_set_cuadro_fac(psfacult, pcestado, pfincuf, pccompani, ppcesion,
                                             picesfij, pccomrea, ppcomisi, picomfij, pisconta,
                                             -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                                             ppreserv, ppresrea, pcintres, pintres, pccorred, pcfreres,
                                             -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                                             pcresrea, pcconrec, pfgarpri, pfgardep, ppimpint,
                                             ptidfcom);
      END IF;

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      vpasexec := 3;
      --
      -- Inicio IAXIS-5361 26/05/2020
      --
      -- Se mueve de lugar el SELECT INTO de la tabla cuafacul para manejar uno solo y no uno por cada IF. Es de suponer que esta función
      -- únicamente se ejecuta si ya existe el facultativo que se usa en psfacult y el siguiente SELECT no arrojará un NO_DATA_FOUND.
      --
      v_ifaccedaux := pifacced;
      
      SELECT cestado, plocal, pfacced, ifacced, nvl(ifaccedini, 0)
        INTO v_cestado, vlocal, v_pfacced, v_ifacced, v_ifaccedini 
        FROM cuafacul
       WHERE sfacult = psfacult;
      --
      -- Fin IAXIS-5361 26/05/2020
      --
      IF pcestado = 2 THEN
         IF (ppcesion > 0) THEN
            FOR r_cuacesfac IN (SELECT SUM(pcesion) pcesion
                                  FROM cuacesfac
                                 WHERE sfacult = psfacult) LOOP

               IF r_cuacesfac.pcesion + NVL(NVL(pplocal, vlocal), 0) <> 100 THEN
                  vnumerr := 104810;   --> No se puede completar. La suma de los porcentajes o de los importes de cesi?n no es correcta
                  RETURN vnumerr;
               --
               -- Inicio IAXIS-5361 26/05/2020
               --
               -- Dado que la pantalla redondea sin cifas decimales el valor de pifacced (que viene con el mismo valor v_ifaccedaux), 
               -- se compara de igual forma con la variable v_ifaccedini redondeada. Esto quiere decir que, de momento, las modificaciones
               -- en decimales del facultativo quedan descartadas.
               --
               ELSIF ROUND(v_ifaccedaux) < ROUND(v_ifaccedini) THEN
                  -- No puede fijarse un facultativo manual menor al calculado por la aplicación por restricciones en la capacidad del 
                  -- contrato.
                  vnumerr := 89908058; 
                  RETURN vnumerr;
               ELSE
                 IF ROUND(v_ifaccedaux) = ROUND(v_ifaccedini) THEN
                   v_ifaccedaux := v_ifaccedini;  
                 END IF;  
                  
                 v_pfacced := ROUND((v_pfacced * v_ifaccedaux) / v_ifacced, 6);  
               -- 
               -- Fin IAXIS-5361 26/05/2020
               --   
                 UPDATE cuafacul
                    SET cestado = pcestado,
                        plocal = NVL(NVL(pplocal, plocal), 0),
                        ffincuf = NVL(pfincuf, ffincuf),
                        ctipfac = NVL(pctipfac, 0),   -- 22374 AVT 20/08/2012
                        ptasaxl = NVL(pptasaxl, ptasaxl),
                        -- Inicio IAXIS-5361 26/05/2020
                        ifacced = NVL(v_ifaccedaux, ifacced), 
                        pfacced = NVL(v_pfacced, pfacced)
                        -- Fin IAXIS-5361 26/05/2020
                  WHERE sfacult = psfacult;
               END IF;
            END LOOP;
         ELSIF(vhaydetalle = 0) THEN
           --
           -- Inicio IAXIS-5361 26/05/2020
           --
           -- De acuerdo a pruebas realizadas, el ELSIF de arriba nunca se ejecuta, sin embargo, se tienen en cuenta las validaciones 
           -- necesarias para la correcta actualización del importe del facultativo en caso de usarse.
           --
           IF  ROUND(v_ifaccedaux) < ROUND(v_ifaccedini) THEN
             -- No puede fijarse un facultativo manual menor al calculado por la aplicación por restricciones en la capacidad del 
             -- contrato.
             vnumerr := 89908058; 
             RETURN vnumerr;
           ELSE
             IF ROUND(v_ifaccedaux) = ROUND(v_ifaccedini) THEN
               v_ifaccedaux := v_ifaccedini;  
             END IF;
           END IF;    
                  
           v_pfacced := ROUND((v_pfacced * v_ifaccedaux) / v_ifacced, 6); 
           --
           -- Fin IAXIS-5361 26/05/2020
           --
           UPDATE cuafacul
              SET cestado = pcestado,
                  plocal = NVL(NVL(pplocal, plocal), 0),
                  ffincuf = NVL(pfincuf, ffincuf),
                  ctipfac = NVL(pctipfac, 0),
                  -- Inicio IAXIS-5361 26/05/2020
                  ifacced = NVL(v_ifaccedaux, ifacced), 
                  pfacced = NVL(v_pfacced, pfacced)
                  -- Fin IAXIS-5361 26/05/2020
            WHERE sfacult = psfacult;
         END IF;
      ELSIF pcestado = 1 THEN

         IF v_cestado = 2 THEN   --Comprobamos que el estado no sea 2, si lo es devolvemos error
            SELECT COUNT('1')
              INTO v_dummy
              FROM cesionesrea
             WHERE sfacult = psfacult;   --Si aun no se ha emitido la p?liza que ha creado el cuadro de facultativo todavia se puede anular

            IF v_dummy > 0 THEN
               vnumerr := 9002126;
               RETURN vnumerr;
            ELSE
               UPDATE cuafacul
                  SET cestado = pcestado
                WHERE sfacult = psfacult;
            END IF;
         END IF;

         --Validar que la suma de PCESION de CUACESFAC <= 100
         SELECT SUM(pcesion) pcesion
           INTO v_pcesion
           FROM cuacesfac
          WHERE sfacult = psfacult;

         IF v_pcesion + NVL(NVL(pplocal, vlocal), 0) > 100 THEN
            vnumerr := 104808;   --> La suma de percentatges no pot ser superior al 100%
            RETURN vnumerr;
         --   
         -- Inicio IAXIS-5361 26/05/2020
         --
         -- Aunque esté en estado incompleto el cuadro, se lanza la validación si el importe del facultativo que intentan fijar
         -- es menor al calculado automáticamente por la aplicación.
         --
         ELSIF ROUND(v_ifaccedaux) < ROUND(v_ifaccedini) THEN
            -- No puede fijarse un facultativo manual menor al calculado por la aplicación por restricciones en la capacidad del contrato.
            vnumerr := 89908058; 
            RETURN vnumerr;
         --   
         -- Fin IAXIS-5361 26/05/2020      
         --
         END IF;
         --
         -- Inicio IAXIS-5361 26/05/2020
         --
         IF ROUND(v_ifaccedaux) = ROUND(v_ifaccedini) THEN
           v_ifaccedaux := v_ifaccedini;  
         END IF;  
         
         v_pfacced := ROUND((v_pfacced * v_ifaccedaux) / v_ifacced, 6);  
         --
         -- Fin IAXIS-5361 26/05/2020
         --

         UPDATE cuafacul
            SET plocal = NVL(NVL(pplocal, plocal), 0),
                ffincuf = NVL(pfincuf, ffincuf),
                ctipfac = NVL(pctipfac, 0),   -- 22374 AVT 20/08/2012
                ptasaxl = NVL(pptasaxl, ptasaxl),
                -- Inicio IAXIS-5361 26/05/2020
                ifacced = NVL(v_ifaccedaux, ifacced), 
                pfacced = NVL(v_pfacced, pfacced)
                -- Fin IAXIS-5361 26/05/2020
          WHERE sfacult = psfacult;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_valida_cuadro_fac', 2,
                     'vpasexec : ' || vpasexec, SQLERRM);
         RETURN 9002120;
   END f_valida_cuadro_fac;

   /*************************************************************************
        Nueva funci?n que inserta los datos correspondientes a las compa??as una vez validados.
        PSFACULT in NUMBER
        PCESTADO in NUMBER
        PFINCUF in DATE
        PCCOMPANI in NUMBER
        PPCESION in NUMBER
        PICESFIJ in NUMBER
        PCCOMREA in NUMBER
        PPCOMISI in NUMBER
        PICOMFIG in NUMBER
        PISCONTA in NUMBER
        PPRESERV in NUMBER
        PCINTRES in NUMBER
        PINTRES in NUMBER

     *************************************************************************/
   FUNCTION f_set_cuadro_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pfincuf IN DATE,
      pccompani IN NUMBER,
      ppcesion IN NUMBER,
      picesfij IN NUMBER,
      pccomrea IN NUMBER,
      ppcomisi IN NUMBER,
      picomfij IN NUMBER,
      pisconta IN NUMBER,
      ppreserv IN NUMBER,
      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      ppresrea IN NUMBER,
      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      pcintres IN NUMBER,
      ppintres IN NUMBER,
      pccorred IN NUMBER,   -- 20/08/2012 AVT 22374
      pcfreres IN NUMBER,
      pcresrea IN NUMBER,
      pcconrec IN NUMBER,
      pfgarpri IN DATE,
      pfgardep IN DATE,
      ppimpint IN NUMBER,
      ptidfcom IN VARCHAR2)   -- bug 25502 17-01-2013 AEG
      RETURN NUMBER IS
      vparam         VARCHAR2(50);
      --pcestado       cuafacul.cestado%TYPE;
      vnumerr        NUMBER := 0;
      v_ifacced      cuafacul.ifacced%TYPE;   --       v_ifacced      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pcesion      NUMBER;
      v_pcesion_def  NUMBER;   -- 27545 KBR 19/07/2013
      v_tot_icesfij  NUMBER;   -- 20994 AVT 20/01/2012
      v_tot_pcesion  NUMBER;   -- 20994 AVT 20/01/2012
      v_plocal       cuafacul.plocal%TYPE;   --       v_plocal       NUMBER;   -- 20994 AVT 20/01/2012 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      --Si el detalle ya existe:
      -- 20994 AVT 20/01/2012 transformar els imports fixes a percentatges
      IF NVL(picesfij, 0) > 0 THEN
         SELECT NVL(ifacced, 0), NVL(plocal, 0)
           INTO v_ifacced, v_plocal
           FROM cuafacul
          WHERE sfacult = psfacult;

         --27545 KBR 19/07/2013
         SELECT NVL(SUM(icesfij), 0), NVL(SUM(pcesion), 0)
           INTO v_tot_icesfij, v_tot_pcesion
           FROM cuacesfac
          WHERE sfacult = psfacult;

         v_tot_icesfij := v_tot_icesfij + NVL(picesfij, 0);

         IF v_ifacced <> 0
            AND v_tot_icesfij = v_ifacced THEN   -- SI JA ESTEM AL FINAL
            v_pcesion := 100 - v_tot_pcesion;
         ELSIF v_ifacced <> 0 THEN
            v_pcesion := (NVL(picesfij, 0) / v_ifacced) * 100;
         ELSE
            v_pcesion := 0;
         END IF;
      END IF;

      p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_cuadro_fac', 1,
                  'v_pcesion : ' || v_pcesion || ' picesfij: ' || picesfij || 'ppcesion: '
                  || ppcesion,
                  SQLERRM);
      --27545 KBR 19/07/2013
      v_pcesion_def := ppcesion;

      IF NVL(ppcesion, 0) = 0 THEN
         v_pcesion_def := v_pcesion;
      ELSE
         IF ppcesion <> v_pcesion THEN
            IF NVL(picesfij, 0) <> 0 THEN
               v_pcesion_def := v_pcesion;
            END IF;
         END IF;
      END IF;

      p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_cuadro_fac', 1,
                  'v_pcesion_def : ' || v_pcesion_def, SQLERRM);

      -- fi 20994 AVT 20/01/2012 --------------------------------------------
      --Si el detalle ya existe:
      -- bug : 25502 17-01-2013 AEG se agrega pimpint
      BEGIN
         --   DBMS_OUTPUT.put_line('ENTRO INSERT : ' || psfacult || ' pccompani ' || pccompani);
         INSERT INTO cuacesfac
                     (sfacult, ccompani, ccomrea, pcesion, icesfij, icomfij,
                      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                      isconta, preserv, presrea, pintres, pcomisi, cintres, ccorred, cfreres,
                      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                      cresrea, cconrec, fgarpri, fgardep, pimpint, tidfcom)
              VALUES (psfacult, pccompani, pccomrea, v_pcesion_def, picesfij, picomfij,
                      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                      pisconta, ppreserv, ppresrea, ppintres, ppcomisi, pcintres, pccorred, pcfreres,
                      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                      pcresrea, pcconrec, pfgarpri, pfgardep, ppimpint, ptidfcom);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            --   DBMS_OUTPUT.put_line('ENTRO UPDATE : ' || psfacult || ' pccompani ' || pccompani);
            UPDATE cuacesfac
               SET pcesion = v_pcesion_def,
                   icesfij = picesfij,
                   ccomrea = pccomrea,
                   pcomisi = ppcomisi,
                   icomfij = picomfij,
                   isconta = pisconta,
                   preserv = ppreserv,
                   -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                   presrea = ppresrea,
                   -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
                   cintres = pcintres,
                   pintres = ppintres,
                   ccorred = pccorred,
                   cfreres = pcfreres,
                   cresrea = pcresrea,
                   cconrec = pcconrec,
                   fgarpri = pfgarpri,
                   fgardep = pfgardep,
                   pimpint = ppimpint,
                   tidfcom = ptidfcom
             WHERE sfacult = psfacult
               AND ccompani = pccompani;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_cuadro_fac', 1,
                     'psfacult : ' || psfacult || ' pccompani: ' || pccompani, SQLERRM);
         RETURN 104345;
   END f_set_cuadro_fac;

/*FIN BUG 10487 : 13/07/2009 : ETM */

   /*BUG 10487 - 02/09/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
          funci?n que se encargar? de borrar un registro de compa??a participante en el cuadro.
          PSFACULT in NUMBER
          PCESTADO in NUMBER
          PCCOMPANI in NUMBER
     *************************************************************************/
   FUNCTION f_anula_cia_fac(psfacult IN NUMBER, pcestado IN NUMBER, pccompani IN NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER := 0;
   BEGIN
      IF psfacult IS NULL THEN
         vnumerr := 9002121;
         RETURN vnumerr;
      END IF;

      IF pccompani IS NULL THEN
         vnumerr := 101734;
         RETURN vnumerr;
      END IF;

      IF pcestado IS NULL THEN
         vnumerr := 801254;   --Estado obligatorio
         RETURN vnumerr;
      ELSIF pcestado <> 1 THEN
         vnumerr := 9002126;
         RETURN vnumerr;
      ELSIF pcestado = 1 THEN   -- AVT 14-10-2009
         DELETE      cuacesfac
               WHERE sfacult = psfacult
                 AND ccompani = pccompani;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.F_ANULA_CIA_FAC', 1,
                     'psfacult : ' || psfacult || ' pccompani: ' || pccompani || ' pcestado :'
                     || pcestado,
                     SQLERRM);
         RETURN 9002122;
   END f_anula_cia_fac;

/*FIN BUG 10487 : 02/09/2009 : ICV */

/*BUG 10990 - 07/09/2009 - 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos*/

   /*************************************************************************
         funci?n que inserta o actualiza informaci?n en cuadroces.
         PCCOMPANI in number,  ob
         PNVERSIO in number, ob
         PSCONTRA in number, ob
         PCTRAMO in number,    ob
         PCCOMREA in number,
         PCESION in number,
         PNPLENOS in number,
         PICESFIJ in number,
         PICOMFIJ in number,
         PISCONTA in number,
         PRESERV in number,
         PINTRES in number,
         PILIACDE in number,
         PPAGOSL in number,
         PCORRED in number,
         PCINTRES in number,
         PCINTREF in number,
         PCRESREF in number,
         PIRESERV in number,
         PTASAJ in number,
         PFUTLIQ in date,
         PIAGREGA in number,
         PIMAXAGR in number,
           -- Bug 18319 - APD - 05/07/2011
           CTIPCOMIS in number,              Tipo Comisi?n
           PCTCOMIS in number,            % Comisi?n fija / provisional
           CTRAMOCOMISION in number,            Tramo comisi?n variable
           -- fin Bug 18319 - APD - 05/07/2011
   *************************************************************************/
   -- INI - AXIS 4451 - 20/06/2019 - AABG - SE AGREGA CAMPO PARA ALMACENAR EL PORCENTAJE DE GASTOS
   FUNCTION f_set_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER,   --ob
      pccomrea IN NUMBER,
      ppcesion IN NUMBER,
      pnplenos IN NUMBER,
      picesfij IN NUMBER,
      picomfij IN NUMBER,
      pisconta IN NUMBER,
      ppreserv IN NUMBER,
      ppintres IN NUMBER,
      piliacde IN NUMBER,
      pppagosl IN NUMBER,
      pccorred IN NUMBER,
      pcintres IN NUMBER,
      pcintref IN NUMBER,
      pcresref IN NUMBER,
      pireserv IN NUMBER,
      pptasaj IN NUMBER,
      pfutliq IN DATE,
      piagrega IN NUMBER,
      pimaxagr IN NUMBER,
      -- Bug 18319 - APD - 05/07/2011
      pctipcomis IN NUMBER,   -- Tipo Comisi?n
      ppctcomis IN NUMBER,   -- % Comisi?n fija / provisional
      pctramocomision IN NUMBER,
      pctgastosrea    IN NUMBER)   --Tramo comisi?n variable
      -- Fin Bug 18319 - APD - 05/07/2011
      -- FIN - AXIS 4451 - 20/06/2019 - AABG - SE AGREGA CAMPO PARA ALMACENAR EL PORCENTAJE DE GASTOS
   RETURN NUMBER IS
      num_err        NUMBER := 0;
      w_100          NUMBER := 0;
      w_total        NUMBER;
      w_retenc       NUMBER;
      w_exces        NUMBER;
      w_excesp       NUMBER;
      v_local        tramos.plocal%TYPE;
      v_itottra      tramos.itottra%TYPE;
      v_ixlprio      tramos.ixlprio%TYPE;
      v_nplenos      tramos.nplenos%TYPE;
      v_ixlexce      tramos.ixlexce%TYPE;
      v_pslexce      tramos.pslexce%TYPE;
      v_pslprio      tramos.pslprio%TYPE;
      v_ctiprea      codicontratos.ctiprea%TYPE;
      v_icapaci      contratos.icapaci%TYPE;
      v_iretenc      contratos.iretenc%TYPE;
      w_icesfij      cuadroces.icesfij%TYPE;
   BEGIN
      IF pccompani IS NULL THEN
         num_err := 101734;
         RETURN num_err;
      END IF;

      IF pnversio IS NULL THEN
         num_err := 9002128;
         RETURN num_err;
      END IF;

      IF pscontra IS NULL THEN
         num_err := 103853;
         RETURN num_err;
      END IF;

      IF pctramo IS NULL THEN
         num_err := 108396;
         RETURN num_err;
      END IF;

      --Controles del tramo
      /*BEGIN
         SELECT plocal, itottra, ixlprio, nplenos, ixlexce, pslexce, pslprio
           INTO v_local, v_itottra, v_ixlprio, v_nplenos, v_ixlexce, v_pslexce, v_pslprio
           FROM tramos
          WHERE nversio = pnversio
            AND scontra = pscontra
            AND ctramo = pctramo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104714;
      END;

      BEGIN
         SELECT ctiprea
           INTO v_ctiprea
           FROM codicontratos
          WHERE scontra = pscontra;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104516;
      END;

      BEGIN
         SELECT icapaci, iretenc
           INTO v_icapaci, v_iretenc
           FROM contratos
          WHERE scontra = pscontra
            AND nversio = pnversio;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104704;
      END;

      --controles.
      IF v_ctiprea = 2 THEN
         w_retenc := v_iretenc;
         w_total := v_iretenc;
      ELSE
         w_retenc := 0;
         w_total := 0;
      END IF;

      -- COMPROBAR QUE ELS % DE CESSIO SUMIN 100 O QUE EL IMPORTS FIXES SUMIN EL TRAM...
      IF pctramo = 1 THEN
         w_100 := NVL(v_local, 0);
      ELSE
         w_100 := 0;
      END IF;

      IF ppcesion IS NOT NULL THEN
         w_100 := w_100 + ppcesion;
      END IF;

      IF picesfij IS NOT NULL THEN
         w_icesfij := w_icesfij + picesfij;
      END IF;

      IF w_100 <> 100
         AND w_100 <> 0 THEN
         p_tab_error (f_sysdate,f_USER,'PAC_REA.F_SET_CUADROCES', 1, 'w_100 : '||w_100,sqlerrm);
         num_err := 103901;
         RETURN num_err;
      END IF;

      IF w_icesfij <> 0
         AND(v_ctiprea = 1
             OR v_ctiprea = 2
             OR v_ctiprea = 9)
         AND w_icesfij <> v_itottra THEN
         RETURN 104189;
      END IF;

      IF w_icesfij <> 0
         AND v_ctiprea = 3
         AND w_icesfij <> v_ixlprio THEN
         RETURN 104189;
      END IF;

      IF v_ctiprea = 1
         OR v_ctiprea = 2
         OR v_ctiprea = 9 THEN
         w_total := w_total + v_itottra;
      END IF;

      -- COMPROBAR QUE ELS TOTALS DE TRAM SIGUIN CORRECTES ( TIPUS 2 )...
      IF NVL(pac_parametros.f_parinstalacion_n('PLENOS_REA'), 0) = 1 THEN
         IF v_ctiprea = 2 THEN
            IF v_itottra <> ROUND((v_nplenos * w_retenc), 2) THEN
               RETURN 104072;
            END IF;
         END IF;
      END IF;

      -- COMPROBAR ENCADENAMENT DE EXCESSOS I PRIORITATS ( TIPUS 3 I 4 )...
      w_exces := NVL(v_ixlexce, 0) + v_ixlprio;
      w_excesp := NVL(v_pslexce, 0) + v_pslprio;

      IF v_ctiprea = 3 THEN
         IF pctramo > 6 THEN
            IF v_ixlexce <> w_exces THEN
               RETURN 104176;
            END IF;
         END IF;
      END IF;

      IF v_ctiprea = 4 THEN
         IF pctramo > 11 THEN
            IF v_pslexce <> w_excesp THEN
               RETURN 104176;
            END IF;
         END IF;
      END IF;

      -- COMPROBAR QUE LA SUMA DELS TOTALS DELS TRAMS = CAPACITAT (TIPUS 1 I 2 )...
      IF (v_ctiprea = 1
          OR v_ctiprea = 2
          OR v_ctiprea = 9) THEN
         IF v_icapaci IS NOT NULL
            AND v_icapaci <> w_total THEN
            RETURN 104071;
         END IF;
      END IF;*/

      --Insert en Cuadroces
      BEGIN
         -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos ctipcomis, pctcomis y ctramocomision
         INSERT INTO cuadroces
                     (ccompani, nversio, scontra, ctramo, ccomrea, pcesion, nplenos,
                      icesfij, icomfij, isconta, preserv, pintres, iliacde, ppagosl,
                      ccorred, cintres, cintref, cresref, ireserv, ptasaj, fultliq,
                      iagrega, imaxagr, ctipcomis, pctcomis, ctramocomision,pctgastos)
              VALUES (pccompani,   --ob
                                pnversio,   --ob
                                         pscontra,   --ob
                                                  pctramo,   --ob
                                                          pccomrea, ppcesion, pnplenos,
                      picesfij, picomfij, pisconta, ppreserv, ppintres, piliacde, pppagosl,
                      pccorred, pcintres, pcintref, pcresref, pireserv, pptasaj, pfutliq,
                      piagrega, pimaxagr, pctipcomis, ppctcomis, pctramocomision, pctgastosrea);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE cuadroces
               SET ccomrea = pccomrea,
                   pcesion = ppcesion,
                   nplenos = pnplenos,
                   icesfij = picesfij,
                   icomfij = picomfij,
                   isconta = pisconta,
                   preserv = ppreserv,
                   pintres = ppintres,
                   iliacde = piliacde,
                   ppagosl = pppagosl,
                   ccorred = pccorred,
                   cintres = pcintres,
                   cintref = pcintref,
                   cresref = pcresref,
                   ireserv = pireserv,
                   ptasaj = pptasaj,
                   fultliq = pfutliq,
                   iagrega = piagrega,
                   imaxagr = pimaxagr,
                   ctipcomis = pctipcomis,
                   pctcomis = ppctcomis,
                   ctramocomision = pctramocomision,
                   pctgastos = pctgastosrea
             WHERE ccompani = pccompani
               AND nversio = pnversio
               AND scontra = pscontra
               AND ctramo = pctramo;
      -- Fin Bug 18319 - APD - 05/07/2011
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_cuadroces', 1,
                     'pnversio : ' || pnversio || ' pccompani: ' || pccompani || ' pscontra :'
                     || pscontra || ' pctramo : ' || pctramo,
                     SQLERRM);
         RETURN 103820;
   END f_set_cuadroces;

   /*************************************************************************
         funci?n que inserta o actualiza informaci?n en tramos.
        --TRAMOS
        PNVERSIO in number--pk
        PSCONTRA in number,--pk
        PCTRAMO in number,--pk
        PITOTTRA in number,
        PNPLENOS in number,
        PCFREBOR in number,--not null
        PLOCAL in number,
        PIXLPRIO in number,
        PIXLEXCE in number,
        PSLPRIO in number,
        PPSLEXCE in number,
        PNCESION in number,
        FULTBOR in date,
        PIMAXPLO in number,
        PNORDEN in number,--not null
        PNSEGCON in number,
        PNSEGVER in number,
        PIMINXL in number,
        PIDEPXL in number,
        PNCTRXL in number,
        PNVERXL in number,
        PTASAXL in number,
        PIPMD in number,
        PCFREPMD in number,
        PCAPLIXL in number,
        PPLIMGAS in number,
        PLIMINX in number,
    *************************************************************************/
   FUNCTION f_set_tramos(
      pnversio IN NUMBER,   --pk
      pscontra IN NUMBER,   --pk
      pctramo IN NUMBER,   --pk
      pitottra IN NUMBER,
      pnplenos IN NUMBER,
      pcfrebor IN NUMBER,   --not null
      pplocal IN NUMBER,
      pixlprio IN NUMBER,
      pixlexce IN NUMBER,
      ppslprio IN NUMBER,
      ppslexce IN NUMBER,
      pncesion IN NUMBER,
      pfultbor IN DATE,
      pimaxplo IN NUMBER,
      pnorden IN NUMBER,   --not null
      pnsegcon IN NUMBER,
      pnsegver IN NUMBER,
      piminxl IN NUMBER,
      pidepxl IN NUMBER,
      pnctrxl IN NUMBER,
      pnverxl IN NUMBER,
      pptasaxl IN NUMBER,
      pipmd IN NUMBER,
      pcfrepmd IN NUMBER,
      pcaplixl IN NUMBER,
      pplimgas IN NUMBER,
      ppliminx IN NUMBER,
      -- Bug 18319 - APD - 04/04/2011
      pidaa IN NUMBER,   -- Deducible anual
      pilaa IN NUMBER,   -- L?mite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicaci?n tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Dep?sito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de dep?sito XL
      ppctminxl IN NUMBER,   -- % Prima M?nima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- C?digo cl?usula Loss Corridor
      pccappedratio IN NUMBER,   -- C?digo cl?usula Capped Ratio
      pcrepos IN NUMBER,   -- C?digo Reposici?n Xl
      pibonorec IN NUMBER,   -- Bono Reclamaci?n
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad seg?n coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisi? de intermediaci?
      pptramo       IN NUMBER,--BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos Q1, Q2, Q3 se adiciona pptramo
      ppreest      IN NUMBER,--BUG CONF-1048  Fecha (29/08/2017) - HRE - se adiciona ppreest
      ppiprio IN NUMBER--Agregar campo prioridad tramo IAXIS-4611
                             )   -- Capacidad seg?n coaseguro
      -- Fin Bug 18319 - APD - 04/04/2011
   RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF pnversio IS NULL THEN
         num_err := 9002128;
         RETURN num_err;
      END IF;

      IF pscontra IS NULL THEN
         num_err := 103853;
         RETURN num_err;
      END IF;

      IF pctramo IS NULL THEN
         num_err := 108396;
         RETURN num_err;
      END IF;

      IF pcfrebor IS NULL THEN
         num_err := 9002129;
         RETURN num_err;
      END IF;

      IF pnorden IS NULL THEN
         num_err := 105553;
         RETURN num_err;
      END IF;

      BEGIN
         -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
         -- idaa, ilaa, ctprimaxl, iprimafijaxl, iprimaestimada, caplictasaxl, ctiptasaxl,
         -- ctramotasaxl, pctpdxl, cforpagpdxl, pctminxl, pctpb, nanyosloss, closscorridor,
         -- cappedratio, crepos, ibonorec, impaviso, impcontado, pctcontado, pctdep,
         --cforpagdep, intdep, pctgastos, ptasaajuste, icapcoaseg
         INSERT INTO tramos
                     (nversio, scontra, ctramo, itottra, nplenos, cfrebor, plocal,
                      ixlprio, ixlexce, pslprio, pslexce, ncesion, fultbor,
                      imaxplo, norden, nsegcon, nsegver, iminxl, idepxl, nctrxl,
                      nverxl, ptasaxl, ipmd, cfrepmd, caplixl, plimgas, pliminx,
                      idaa, ilaa, ctprimaxl, iprimafijaxl, iprimaestimada,
                      caplictasaxl, ctiptasaxl, ctramotasaxl, pctpdxl, cforpagpdxl,
                      pctminxl, pctpb, nanyosloss, closscorridor, ccappedratio, crepos,
                      ibonorec, impaviso, impcontado, pctcontado, pctgastos,
                      ptasaajuste, icapcoaseg, icostofijo, pcomisinterm, ptramo,--BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos Q1, Q2, Q3 se adiciona ptramo
                      preest,iprio)
              VALUES (pnversio,   --pk
                               pscontra,   --pk
                                        pctramo,   --pk
                                                pitottra, pnplenos, pcfrebor,   --not null
                                                                             pplocal,
                      pixlprio, pixlexce, ppslprio, ppslexce, NVL(pncesion, 0), pfultbor,
                      pimaxplo, pnorden,   --not null
                                        pnsegcon, pnsegver, piminxl, pidepxl, pnctrxl,
                      pnverxl, pptasaxl, pipmd, pcfrepmd, pcaplixl, pplimgas, ppliminx,
                      pidaa, pilaa, pctprimaxl, piprimafijaxl, piprimaestimada,
                      pcaplictasaxl, pctiptasaxl, pctramotasaxl, ppctpdxl, pcforpagpdxl,
                      ppctminxl, ppctpb, pnanyosloss, pclosscorridor, pccappedratio, pcrepos,
                      pibonorec, pimpaviso, pimpcontado, ppctcontado, ppctgastos,
                      pptasaajuste, picapcoaseg, picostofijo, ppcomisinterm, pptramo,--BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos Q1, Q2, Q3 se adiciona pptramo
                      ppreest,ppiprio);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE tramos
               SET itottra = pitottra,
                   nplenos = pnplenos,
                   cfrebor = pcfrebor,
                   plocal = pplocal,
                   ixlprio = pixlprio,
                   ixlexce = pixlexce,
                   pslprio = ppslprio,
                   pslexce = ppslexce,
                   ncesion = NVL(pncesion, NVL(ncesion, 0)),
                   fultbor = pfultbor,
                   imaxplo = pimaxplo,
                   norden = pnorden,
                   nsegcon = pnsegcon,
                   nsegver = pnsegver,
                   iminxl = piminxl,
                   idepxl = pidepxl,
                   nctrxl = pnctrxl,
                   nverxl = pnverxl,
                   ptasaxl = pptasaxl,
                   ipmd = pipmd,
                   cfrepmd = pcfrepmd,
                   caplixl = pcaplixl,
                   plimgas = pplimgas,
                   pliminx = ppliminx,
                   idaa = pidaa,
                   ilaa = pilaa,
                   ctprimaxl = pctprimaxl,
                   iprimafijaxl = piprimafijaxl,
                   iprimaestimada = piprimaestimada,
                   caplictasaxl = pcaplictasaxl,
                   ctiptasaxl = pctiptasaxl,
                   ctramotasaxl = pctramotasaxl,
                   pctpdxl = ppctpdxl,
                   cforpagpdxl = pcforpagpdxl,
                   pctminxl = ppctminxl,
                   pctpb = ppctpb,
                   nanyosloss = pnanyosloss,
                   closscorridor = pclosscorridor,
                   ccappedratio = pccappedratio,
                   crepos = pcrepos,
                   ibonorec = pibonorec,
                   impaviso = pimpaviso,
                   impcontado = pimpcontado,
                   pctcontado = ppctcontado,
                   pctgastos = ppctgastos,
                   ptasaajuste = pptasaajuste,
                   icapcoaseg = picapcoaseg,
                   icostofijo = picostofijo,
                   pcomisinterm = ppcomisinterm,
                   ptramo = pptramo,--BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos Q1, Q2, Q3
                   preest = ppreest,
                   iprio=ppiprio -- Agregar campo de prioridad tramo IAXIS-4611
             WHERE nversio = pnversio
               AND scontra = pscontra
               AND ctramo = pctramo;
      -- Fin Bug 18319 - APD - 06/07/2011
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_tramos', 1,
                     'pnversio : ' || pnversio || ' pscontra :' || pscontra || ' pctramo : '
                     || pctramo,
                     SQLERRM);
         RETURN 103819;
   END f_set_tramos;

   /*************************************************************************
        funci?n que inserta o actualiza informaci?n en contratos.
        PSCONTRA in number,
        PNVERSIO in number,
        PNPRIORI in number, --not null
        PFCONINI in date, --not null
        PNCONREL in number,
        PFCONFIN in date,
        PIAUTORI in number,
        PIRETENC in number,
        PIMINCES in number,
        PICAPACI in number,
        PIPRIOXL in number,
        PPPRIOSL in number,
        PTCONTRA in varchar2,
        PTOBSERV in varchar2
        PPCEDIDO in number,
        PPRIESGOS in number,
        PPDESCUENTO in number,
        PPGASTOS in number,
        PPARTBENE in number,
        PCREAFAC in number,
        PPCESEXT in number,
        PCGARREL in number,
        PCFRECUL in number,
        PSCONQP in number,
        PNVERQP in number,
        PIAGREGA in number, comunes con cuadroces
        PIMAXAGR in number
    *************************************************************************/
   FUNCTION f_set_contratos(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pnpriori IN NUMBER,   --not null
      pfconini IN DATE,   --not null
      pnconrel IN NUMBER,
      pfconfin IN DATE,
      piautori IN NUMBER,
      piretenc IN NUMBER,
      piminces IN NUMBER,
      picapaci IN NUMBER,
      piprioxl IN NUMBER,
      pppriosl IN NUMBER,
      ptcontra IN VARCHAR2,
      ptobserv IN VARCHAR2,
      ppcedido IN NUMBER,
      ppriesgos IN NUMBER,
      ppdescuento IN NUMBER,
      ppgastos IN NUMBER,
      pppartbene IN NUMBER,
      pcreafac IN NUMBER,
      ppcesext IN NUMBER,
      pcgarrel IN NUMBER,
      pcfrecul IN NUMBER,
      psconqp IN NUMBER,
      pnverqp IN NUMBER,
      piagrega IN NUMBER,
      pimaxagr IN NUMBER,
      -- Bug 18319 - APD - 04/07/2011
      pclavecbr NUMBER,   -- F?rmula para el CBR --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcercartera NUMBER,   -- Tipo E/R cartera --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la versi?n --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pnanyosloss NUMBER,   -- A?os Loss-Corridos --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcbasexl NUMBER,   -- Base para el c?lculo XL --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pclosscorridor NUMBER,   -- C?digo cl?usula Loss Corridor --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pccappedratio NUMBER,   -- C?digo cl?usula Capped Ratio --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pscontraprot NUMBER,   -- Contrato XL protecci?n --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcestado NUMBER,   --Estado de la versi?n
      pnversioprot NUMBER,   -- Version del Contrato XL protecci?n --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pncomext NUMBER, --%Comisión extra prima (solo para POSITIVA) --AGG 14/05/2014 Se añade la comisión de la extra prima
      pnretpol IN NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul IN NUMBER --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
	  )   
      -- Fin Bug 18319 - APD - 04/07/2011
   RETURN NUMBER IS
      num_err        NUMBER := 0;
      vfconfin       DATE; --CONF-910
      vfconfinaux    DATE; --CONF-910
   BEGIN
      IF pnversio IS NULL THEN
         num_err := 9002128;
         RETURN num_err;
      END IF;

      IF pscontra IS NULL THEN
         num_err := 103853;
         RETURN num_err;
      END IF;

      /*IF pnpriori IS NULL THEN
         num_err := 9002130;
         RETURN num_err;
      END IF;*/
      IF pfconini IS NULL THEN
         num_err := 105308;
         RETURN num_err;
      END IF;

      --CONF-910 Inicio
      vfconfin := pfconini;
      IF NVL(pac_parametros.f_parempresa_n(24, 'INFORMA_FECHA_FIN'),0) = 1 THEN
        vfconfinaux := pfconfin;
      ELSE
        vfconfinaux := NULL;
      END IF;
      --CONF-910 End

      BEGIN
         -- Bug 18319 - APD - 06/07/2011 - se a?aden los campos
         -- clavecbr, cercartera, iprimaesperadas, nanyosloss,
         -- cbasexl, closscorridor, ccappedratio, scontraprot, cestado
         INSERT INTO contratos
                     (scontra, nversio, npriori, fconini, nconrel, fconfin,
                      iautori, iretenc, iminces, icapaci, iprioxl, ppriosl, tcontra,
                      tobserv, pcedido, priesgos, pdescuento, pgastos, ppartbene,
                      creafac, pcesext, cgarrel, cfrecul, sconqp, nverqp, iagrega,
                      imaxagr, clavecbr, cercartera, iprimaesperadas, nanyosloss,
                      cbasexl, closscorridor, ccappedratio, scontraprot, cestado,
                      nversioprot, pcomext, fconfinaux, nretpol, nretcul) --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
              VALUES (pscontra, pnversio, NVL(pnpriori, 0),   --not null
                                                           pfconini,   --not null
                                                                    pnconrel, vfconfin, --CONF-910
                      piautori, piretenc, piminces, picapaci, piprioxl, pppriosl, ptcontra,
                      ptobserv, ppcedido, ppriesgos, ppdescuento, ppgastos, pppartbene,
                      pcreafac, ppcesext, pcgarrel, pcfrecul, psconqp, pnverqp, piagrega,
                      pimaxagr, pclavecbr, pcercartera, piprimaesperadas, pnanyosloss,
                      pcbasexl, pclosscorridor, pccappedratio, pscontraprot, pcestado,
                      pnversioprot, pncomext, vfconfinaux, pnretpol, pnretcul); --CONF-910   -- AGG 14/05/2014 se a?de la comisi? de la extra prima --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL y Retencion por Cumulo NRETCUL
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE contratos
               SET npriori = NVL(pnpriori, 0),
                   fconini = pfconini,
                   nconrel = pnconrel,
                   fconfin = vfconfin, --CONF-910
                   iautori = piautori,
                   iretenc = piretenc,
                   iminces = piminces,
                   icapaci = picapaci,
                   iprioxl = piprioxl,
                   ppriosl = pppriosl,
                   tcontra = ptcontra,
                   tobserv = ptobserv,
                   pcedido = ppcedido,
                   priesgos = ppriesgos,
                   pdescuento = ppdescuento,
                   pgastos = ppgastos,
                   ppartbene = pppartbene,
                   creafac = pcreafac,
                   pcesext = ppcesext,
                   cgarrel = pcgarrel,
                   cfrecul = pcfrecul,
                   sconqp = psconqp,
                   nverqp = pnverqp,
                   iagrega = piagrega,
                   imaxagr = pimaxagr,
                   clavecbr = pclavecbr,
                   cercartera = pcercartera,
                   iprimaesperadas = piprimaesperadas,
                   nanyosloss = pnanyosloss,
                   cbasexl = pcbasexl,
                   closscorridor = pclosscorridor,
                   ccappedratio = pccappedratio,
                   scontraprot = pscontraprot,
                   cestado = pcestado,
                   nversioprot = pnversioprot,
                   pcomext = pncomext,   -- AGG 14/05/2014 se a?de la comisi? de la extra prima
                   fconfinaux = vfconfinaux, --CONF-910
				   nretpol = pnretpol, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
				   nretcul = pnretcul  --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
             WHERE scontra = pscontra
               AND nversio = pnversio;
      -- fin Bug 18319 - APD - 06/07/2011
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_contratos', 1,
                     'pnversio : ' || pnversio || ' pscontra :' || pscontra, SQLERRM);
         RETURN 103818;
   END f_set_contratos;

   /*************************************************************************
          funci?n que inserta o actualiza informaci?n en codicontratos.
          PSCONTRA in number,--pk
          PSPLENO in number,
          PCEMPRES in number, --not null,
          PCTIPREA in number, --not null
          PFINICTR in date, -- not null
          PCRAMO in number,
          PCACTIVI in number,
          PCMODALI in number,
          PCCOLECT in number,
          PCTIPSEG in number,
          PCGARANT in number,
          PFFINCTR in date
          PNCONREL in number,
          PSCONAGR in number,
          PCVIDAGA in number,
          PCVIDAIR in number,
          PCTIPCUM in number,
          PCVALID in number
          PCMONEDA in varchar  -- Bug 18319 - APD - 04/07/2011
          PTDESCRIPCION in varchar  -- Bug 18319 - APD - 04/07/2011
      *************************************************************************/
   FUNCTION f_set_codicontratos(
      pscontra IN NUMBER,   --pk
      pspleno IN NUMBER,
      pcempres IN NUMBER,   --not null,
      pctiprea IN NUMBER,   --not null
      pfinictr IN DATE,   -- not null
      pcramo IN NUMBER,
      pcactivi IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcgarant IN NUMBER,
      pffinctr IN DATE,
      pnconrel IN NUMBER,
      psconagr IN NUMBER,
      pcvidaga IN NUMBER,
      pcvidair IN NUMBER,
      pctipcum IN NUMBER,
      pcvalid IN NUMBER,
      pcmoneda IN VARCHAR,   -- Bug 18319 - APD - 04/07/2011
      ptdescripcion IN VARCHAR,
      pcdevento IN NUMBER, -- Bug 18319 - APD - 04/07/2011
      pnversio IN NUMBER)   -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF pscontra IS NULL THEN
         num_err := 103853;
         RETURN num_err;
      END IF;

      IF pcempres IS NULL THEN
         num_err := 180500;
         RETURN num_err;
      END IF;

      IF pctiprea IS NULL THEN
         num_err := 9002131;
         RETURN num_err;
      END IF;

      IF pfinictr IS NULL THEN
         num_err := 9002132;
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO codicontratos
                     (scontra, spleno, cempres, ctiprea, finictr,
                                                                 -- cramo, cactivi, cmodali, ccolect, ctipseg, cgarant, -- 14536 18-05-2010 AVT
                                                                 ffinctr, nconrel,
                      sconagr, cvidaga, cvidair, ctipcum, cvalid, cmoneda,
                      tdescripcion, cdevento)
              VALUES (pscontra, pspleno, pcempres,   --not null,
                                                  pctiprea,   --not null
                                                           pfinictr,   -- not null
                                                                    --pcramo, pcactivi, pcmodali, pccolect, pctipseg, pcgarant, -- 14536 18-05-2010 AVT
                                                                    pffinctr, pnconrel,
                      psconagr, pcvidaga, pcvidair, pctipcum, pcvalid, pcmoneda,
                      ptdescripcion, pcdevento);                     
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE codicontratos
               SET spleno = pspleno,
                   cempres = pcempres,
                   ctiprea = pctiprea,
                   finictr = pfinictr,
                   -- cramo = pcramo, -- 14536 18-05-2010 AVT ini
                   -- cactivi = pcactivi,
                   -- cmodali = pcmodali,
                   -- ccolect = pccolect,
                   -- ctipseg = pctipseg,
                   -- cgarant = pcgarant, -- 14536 18-05-2010 AVT  fi
                   ffinctr = pffinctr,
                   nconrel = pnconrel,
                   sconagr = psconagr,
                   cvidaga = pcvidaga,
                   cvidair = pcvidair,
                   ctipcum = pctipcum,
                   cvalid = pcvalid,
                   cmoneda = pcmoneda,   -- Bug 18319 - APD - 04/07/2011
                   tdescripcion = ptdescripcion   -- Bug 18319 - APD - 04/07/2011
             WHERE scontra = pscontra;
      END;

      -- Bug 18319 - APD - 11/07/2011 - solo se debe insertar/actualizar en la tabla
      -- AGR_CONTRATOS si el pcramo est? informado
      IF pcramo IS NOT NULL THEN
         -- 14536 18-05-2010 AVT S'afegeix l'actualitzaci? de la nova taula AGR_CONTRATOS
         BEGIN
            -- Bug 18319 - APD - 05/07/2011 - se a?ade el campo NVERSIO
            INSERT INTO agr_contratos
                        (scontra, cramo, cactivi, cmodali, ccolect, ctipseg,
                         cgarant, nversio)
                 VALUES (pscontra, pcramo, pcactivi, pcmodali, pccolect, pctipseg,
                         pcgarant, pnversio);
         EXCEPTION
         -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA AL WHERE FILTROS POR PK
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE agr_contratos
                  SET --cramo = pcramo,
                      cactivi = pcactivi,
                      cmodali = pcmodali,
                      ccolect = pccolect,
                      ctipseg = pctipseg,
                      cgarant = pcgarant
                      --nversio = pnversio
               WHERE  scontra = pscontra AND cramo = pcramo AND nversio = pnversio;
         -- fin Bug 18319 - APD - 05/07/2011
         -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA AL WHERE FILTROS POR PK
         END;
      END IF;

      -- Fin Bug 18319 - APD - 11/07/2011
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_codicontratos', 1,
                     ' pscontra :' || pscontra, SQLERRM);
         RETURN 104070;
   END f_set_codicontratos;
   -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS

/*FIN BUG 10990 : 07/09/2009 : ICV */

   /*BUG 11353 - 12/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */

   /*************************************************************************
       Funci?n que valida la introducci?n o modificaci?n de un contrato de reaseguro
       Devuelve un number con 0 si todo ha ido correcto o el n?mero de error en caso contrario
   *************************************************************************/
    -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la funcion aqui y se pasa a  pac_md_rea.
   /*************************************************************************
   Funci?n que inserta / actualiza las formulas del reaseguro
   *************************************************************************/
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF pnversio IS NULL THEN
         num_err := 9002128;
         RETURN num_err;
      END IF;

      IF pscontra IS NULL THEN
         num_err := 103853;
         RETURN num_err;
      END IF;

      IF pcgarant IS NULL THEN
         num_err := 9001413;
         RETURN num_err;
      END IF;

      IF pccampo IS NULL THEN
         num_err := 1000165;
         RETURN num_err;
      END IF;

      IF pclave IS NULL THEN
         num_err := 108559;   -- No se ha seleccionado ninguna f?rmula.
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO reaformula
                     (scontra, nversio, cgarant, ccampo, clave, sproduc)
              VALUES (pscontra, pnversio, pcgarant, pccampo, pclave, psproduc);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
/*
            UPDATE reaformula r
               SET sproduc = psproduc
             WHERE r.scontra = pscontra
               AND r.nversio = pnversio
               AND r.cgarant = pcgarant
               AND r.ccampo = pccampo
               AND r.clave = pclave;
*/
            UPDATE reaformula r
               SET clave = pclave
             WHERE r.scontra = pscontra
               AND r.nversio = pnversio
               AND r.cgarant = pcgarant
               AND r.ccampo = pccampo
               AND((r.sproduc IS NULL
                    AND psproduc IS NULL)
                   OR(r.sproduc = psproduc
                      AND psproduc IS NOT NULL));
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_reaformula', 2,
                     'pscontra : ' || pscontra || ' pnversio : ' || pnversio || ' pcgarant : '
                     || pcgarant || ' pccampo : ' || pccampo || ' pclave : ' || pclave,
                     SQLERRM);
         RETURN 108468;
   END f_set_reaformula;

    /*************************************************************************
   Funci?n que inserta / actualiza las cuentas t?cnicas del reaseguro
   *************************************************************************/
   FUNCTION f_set_ctatecnica(
      pccompani IN NUMBER,   --pk
      pscontra IN NUMBER,   --pk
      pnversio IN NUMBER,   --pk
      pctramo IN NUMBER,   --pk
      pnctatec IN NUMBER,
      pcfrecul IN NUMBER,
      pcestado IN NUMBER,
      pfestado IN DATE,
      pfultimp IN DATE,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pccorred IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF pnversio IS NULL THEN
         num_err := 9002128;
         RETURN num_err;
      END IF;

      IF pscontra IS NULL THEN
         num_err := 103853;
         RETURN num_err;
      END IF;

      IF pccompani IS NULL THEN
         num_err := 101734;   --> Falta compa??a
         RETURN num_err;
      END IF;

      IF pctramo IS NULL THEN
         num_err := 108396;
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO ctatecnica
                     (ccompani, nversio, scontra, ctramo, nctatec, cfrecul, cestado,
                      festado, fcierre, cempres, sproduc, ccorred)
              VALUES (pccompani, pnversio, pscontra, pctramo, pnctatec, pcfrecul, pcestado,
                      pfestado, pfultimp, pcempres, NVL(psproduc, 0), pccorred);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE ctatecnica c
               SET nctatec = pnctatec,
                   cfrecul = pcfrecul,
                   cestado = pcestado,
                   festado = pfestado,
                   fcierre = pfultimp
             WHERE c.scontra = pscontra
               AND c.nversio = pnversio
               AND c.ccompani = pccompani
               AND c.ctramo = pctramo
               AND NVL(c.sproduc, 0) = psproduc;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_ctatecnica', 2,
                     'pscontra : ' || pscontra || ' pnversio : ' || pnversio
                     || ' pccompani : ' || pccompani || ' pctramo : ' || pctramo,
                     SQLERRM);
         RETURN 108468;
   END f_set_ctatecnica;

/*FIN BUG 11353 : 12/10/2009 : ICV */

   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER)   --ob
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      DELETE FROM cuadroces
            WHERE scontra = pscontra
              AND nversio = pnversio
              AND ctramo = pctramo
              AND ccompani = pccompani;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_cuadroces', 2,
                     'pscontra : ' || pscontra || ' pnversio : ' || pnversio
                     || ' pccompani : ' || pccompani || ' pctramo : ' || pctramo,
                     SQLERRM);
         RETURN 103870;
   END f_del_cuadroces;

   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_tramos(pnversio IN NUMBER, pscontra IN NUMBER, pctramo IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      DELETE FROM tramos
            WHERE scontra = pscontra
              AND nversio = pnversio
              AND ctramo = pctramo;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_tramos', 2,
                     'pscontra : ' || pscontra || ' pnversio : ' || pnversio || ' pctramo : '
                     || pctramo,
                     SQLERRM);
         RETURN 103870;
   END f_del_tramos;

   /*************************************************************************
   Funci?n que graba una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_clausulas_reas(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      pfefecto IN DATE DEFAULT f_sysdate,
      pfvencim IN DATE)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pccodigo IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF pctipo IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      -- pcmodo = 1.-ALTA; 2.-MODIFICACION
      IF NVL(pcmodo, 1) = 1 THEN
         -- En modo alta se debe validar que el c?digo nuevo no exista en la tabla COD_CLAUSULAS_REAS
         SELECT COUNT(1)
           INTO vcont
           FROM cod_clausulas_reas
          WHERE ccodigo = pccodigo;

         IF vcont <> 0 THEN
            num_err := 101247;   -- Este c?digo ya existe
            RETURN num_err;
         END IF;
      END IF;

      IF pfvencim IS NOT NULL THEN
         IF pfvencim < pfefecto THEN
            num_err := 152064;   -- La fecha de vencimiento no puede ser inferior a la fecha efecto
            RETURN num_err;
         END IF;
      END IF;

      --Insert
      BEGIN
         -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos ctipcomis, pctcomis y ctramocomision
         INSERT INTO cod_clausulas_reas
                     (ccodigo, ctipo, fefecto, fvencim)
              VALUES (pccodigo, pctipo, pfefecto, pfvencim);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            -- Aqui entrara si se est? modificando el registro (pcmodo = 2)
            UPDATE cod_clausulas_reas
               SET ctipo = pctipo,
                   fefecto = pfefecto,
                   fvencim = pfvencim
             WHERE ccodigo = pccodigo;
      -- Fin Bug 18319 - APD - 05/07/2011
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_cod_clausulas_reas', 1,
                     'par?metros- pcodigo : ' || pccodigo || '; pctipo : ' || pctipo
                     || '; pfefecto : ' || pfefecto || '; pfvencim : ' || pfvencim,
                     SQLERRM);
         RETURN 103820;
   END f_set_cod_clausulas_reas;

   /*************************************************************************
   Funci?n que guarda una descripci?n de una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF pccodigo IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF pcidioma IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF ptdescripcion IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      --Insert en Cuadroces
      BEGIN
         -- Bug 18319 - APD - 05/07/2011 - se a?aden los campos ctipcomis, pctcomis y ctramocomision
         INSERT INTO clausulas_reas
                     (ccodigo, cidioma, tdescripcion)
              VALUES (pccodigo, pcidioma, ptdescripcion);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE clausulas_reas
               SET tdescripcion = ptdescripcion
             WHERE ccodigo = pccodigo
               AND cidioma = pcidioma;
      -- Fin Bug 18319 - APD - 05/07/2011
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_clausulas_reas', 1,
                     'par?metros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma
                     || '; ptdescripcion : ' || ptdescripcion,
                     SQLERRM);
         RETURN 103820;
   END f_set_clausulas_reas;

   /*************************************************************************
   Funci?n que guarda un tramo de una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      pilim_inf IN NUMBER,
      pilim_sup IN NUMBER,
      ppctpart IN NUMBER,
      ppctmin IN NUMBER,
      ppctmax IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
------------------------------------
-- Se validan campos obligatorios --
------------------------------------
      IF pccodigo IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF pctramo IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF pilim_inf IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF pilim_sup IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

------------------------------
-- Se realizan validaciones --
------------------------------
-- se valida que el campo ctramo no exista ya (no se puede repetir)
-- para el mismo ccodigo si se est? realizando una Alta
      IF pcmodo = 1 THEN   -- 1.-Alta, 2.-Modif.
         SELECT COUNT(1)
           INTO vcont
           FROM clausulas_reas_det
          WHERE ccodigo = pccodigo
            AND ctramo = pctramo;

         IF vcont <> 0 THEN
            num_err := 9901536;   -- Ya existe esta ordenaci?n
            RETURN num_err;
         END IF;
      END IF;

      -- se valida que el limite inferior sea menor o igual al limite superior
      IF pilim_inf > pilim_sup THEN
         num_err := 111104;   -- El valor m?ximo no puede ser inferior al m?nimo
         RETURN num_err;
      END IF;

      -- se valida que el % Min sea menor o igual al % Max
      IF ppctmin IS NOT NULL
         AND ppctmax IS NOT NULL THEN
         IF ppctmin > ppctmax THEN
            num_err := 111104;   -- El valor m?ximo no puede ser inferior al m?nimo
            RETURN num_err;
         END IF;
      END IF;

------------
-- Insert --
------------
      BEGIN
         INSERT INTO clausulas_reas_det
                     (ccodigo, ctramo, ilim_inf, ilim_sup, pctpart, pctmin, pctmax)
              VALUES (pccodigo, pctramo, pilim_inf, pilim_sup, ppctpart, ppctmin, ppctmax);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE clausulas_reas_det
               SET ilim_sup = pilim_sup,
                   pctpart = ppctpart,
                   pctmin = ppctmin,
                   pctmax = ppctmax
             WHERE ccodigo = pccodigo
               AND ctramo = pctramo
               AND ilim_inf = pilim_inf;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_clausulas_reas_det', 1,
                     'par?metros- pccodigo : ' || pccodigo || '; pctramo : ' || pctramo
                     || '; pilim_inf : ' || pilim_inf || '; pilim_sup : ' || pilim_sup
                     || '; ppctpart : ' || ppctpart || '; ppctmin : ' || ppctmin
                     || '; ppctmax : ' || ppctmax,
                     SQLERRM);
         RETURN 103820;
   END f_set_clausulas_reas_det;

   /*************************************************************************
   Funci?n que elimina una descripci?n una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas(pccodigo IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      DELETE FROM clausulas_reas
            WHERE ccodigo = pccodigo
              AND cidioma = pcidioma;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_clausulas_reas', 2,
                     'pccodigo : ' || pccodigo || ' pcidioma : ' || pcidioma, SQLERRM);
         RETURN 103870;
   END f_del_clausulas_reas;

   /*************************************************************************
   Funci?n que elimina un tramo una cl?usula de reaseguro o un tramo escalonado
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas_det(pccodigo IN NUMBER, pctramo IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      DELETE FROM clausulas_reas_det
            WHERE ccodigo = pccodigo
              AND ctramo = pctramo;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_clausulas_reas_det', 2,
                     'pccodigo : ' || pccodigo || ' pctramo : ' || pctramo, SQLERRM);
         RETURN 103870;
   END f_del_clausulas_reas_det;

/*************************************************************************
Funci?n que graba una reposicion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_reposicion(pccodigo IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   --nuevo_codigo   NUMBER;
   BEGIN
      IF pccodigo IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      BEGIN
         /*SELECT max(ccodigo) INTO nuevo_codigo
         from cod_reposicion;

         nuevo_codigo := nuevo_codigo + 1;*/
         INSERT INTO cod_reposicion
                     (ccodigo)
              VALUES (pccodigo);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
/*
            UPDATE cod_reposicion
               SET ctipo = pctipo,
                   fefecto = pfefecto,
                   fvencim = pfvencim
             WHERE ccodigo = pccodigo;
*/
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_cod_reposicion', 1,
                     'par?metros- pccodigo : ' || pccodigo, SQLERRM);
         RETURN 103820;
   END f_set_cod_reposicion;

   /*************************************************************************
   Funci?n que guarda una descripci?n de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF pccodigo IS NULL
         OR pcidioma IS NULL
         OR ptdescripcion IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO reposiciones
                     (ccodigo, cidioma, tdescripcion)
              VALUES (pccodigo, pcidioma, ptdescripcion);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE reposiciones
               SET tdescripcion = ptdescripcion
             WHERE ccodigo = pccodigo
               AND cidioma = pcidioma;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_reposiciones', 1,
                     'par?metros- pccodigo : ' || pccodigo || '; pcidioma : ' || pcidioma
                     || '; ptdescripcion : ' || ptdescripcion,
                     SQLERRM);
         RETURN 9907219;
   END f_set_reposiciones;

   /*************************************************************************
   Funci?n que guarda un tramo de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      picapacidad IN NUMBER,
      pptasa IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
------------------------------------
-- Se validan campos obligatorios --
------------------------------------
      IF pccodigo IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF pnorden IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

------------------------------
-- Se realizan validaciones --
------------------------------
-- se valida que el campo norden no exista ya (no se puede repetir)
-- para el mismo ccodigo si se est? realizando una Alta
      IF pcmodo = 1 THEN   -- 1.-Alta, 2.-Modif.
         SELECT COUNT(1)
           INTO vcont
           FROM reposiciones_det
          WHERE ccodigo = pccodigo
            AND norden = pnorden;

         IF vcont <> 0 THEN
            num_err := 9901536;   -- Ya existe esta ordenaci?n
            RETURN num_err;
         END IF;
      END IF;

      --Insert
      BEGIN
         INSERT INTO reposiciones_det
                     (ccodigo, norden, icapacidad, ptasa)
              VALUES (pccodigo, pnorden, picapacidad, pptasa);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE reposiciones_det
               SET icapacidad = picapacidad,
                   ptasa = pptasa
             WHERE ccodigo = pccodigo
               AND norden = pnorden;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_reposiciones_det', 1,
                     'par?metros- pccodigo : ' || pccodigo || '; pnorden : ' || pnorden
                     || '; picapacidad : ' || picapacidad || '; pptasa : ' || pptasa,
                     SQLERRM);
         RETURN 103820;
   END f_set_reposiciones_det;

   /*************************************************************************
   Funci?n que elimina una reposici?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_cod_reposicion(pccodigo IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
------------------------------
-- Se realizan validaciones --
------------------------------
      SELECT COUNT(1)
        INTO vcont
        FROM reposiciones_det
       WHERE ccodigo = pccodigo;

      -- si existen valores en la tabla REPOSICIONES_DET no se puede borrar
      -- la cabecera (tablas COD_REPOSICION Y REPOSICIONES)
      IF vcont <> 0 THEN
         RETURN 2292;   -- No se puede borrar. Existen registros asociados.
      END IF;

------------------------------
-- DELETE --
------------------------------
      DELETE FROM reposiciones
            WHERE ccodigo = pccodigo;

      DELETE FROM cod_reposicion
            WHERE ccodigo = pccodigo;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_cod_reposicion', 2,
                     'pccodigo : ' || pccodigo || ' pcidioma : ' || pcidioma, SQLERRM);
         RETURN 103870;
   END f_del_cod_reposicion;

   /*************************************************************************
   Funci?n que elimina un detalle de una reposici?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reposiciones_det(pccodigo IN NUMBER, pnorden IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      DELETE FROM reposiciones_det
            WHERE ccodigo = pccodigo
              AND norden = pnorden;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_reposiciones_det', 2,
                     'pccodigo : ' || pccodigo || ' pnorden : ' || pnorden, SQLERRM);
         RETURN 103870;
   END f_del_reposiciones_det;

   /*************************************************************************
   Funci?n que guarda una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agrupcontrato(psconagr IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF psconagr IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO codicontratosagr
                     (sconagr)
              VALUES (psconagr);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
/*
            UPDATE codicontratosagr
               SET sconagr = psconagr
             WHERE sconagr = psconagr;
*/
            NULL;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_agrupcontrato', 1,
                     'par?metros- psconagr : ' || psconagr, SQLERRM);
         RETURN 103820;
   END f_set_agrupcontrato;

   /*************************************************************************
   Funci?n que guarda una descripcion de una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_desagrupcontrato(psconagr IN NUMBER, pcidioma IN NUMBER, ptconagr IN VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF psconagr IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      IF pcidioma IS NULL THEN
         num_err := 9001768;   -- Faltan campos obligatorios por entrar
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO descontratosagr
                     (sconagr, cidioma, tconagr)
              VALUES (psconagr, pcidioma, ptconagr);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE descontratosagr
               SET tconagr = ptconagr
             WHERE sconagr = psconagr
               AND cidioma = pcidioma;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_desagrupcontrato', 1,
                     'par?metros- psconagr : ' || psconagr || '; pcidioma : ' || pcidioma
                     || '; ptconagr : ' || ptconagr,
                     SQLERRM);
         RETURN 103820;
   END f_set_desagrupcontrato;

/*************************************************************************
Funci?n que graba una asociacion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pilimsub IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcont          NUMBER;
      vcramo         agr_contratos.cramo%TYPE;
      vcmodali       agr_contratos.cmodali%TYPE;
      vccolect       agr_contratos.ccolect%TYPE;
      vctipseg       agr_contratos.ctipseg%TYPE;
   BEGIN
      IF pscontra IS NULL THEN
         num_err := 103853;   -- N? de contrato obligatorio
         RETURN num_err;
      END IF;

      IF pcramo IS NULL THEN
         num_err := 1000022;   -- El campo c?digo del ramo no est? informado
         RETURN num_err;
      END IF;

      vcramo := pcramo;
      vcmodali := pcmodali;
      vccolect := pccolect;
      vctipseg := pctipseg;

      IF psproduc IS NOT NULL THEN
         SELECT cramo, cmodali, ccolect, ctipseg
           INTO vcramo, vcmodali, vccolect, vctipseg
           FROM productos
          WHERE sproduc = psproduc;
      ELSE
         -- se valida que los parametros introducidos esten informados si son necesarios
         IF vctipseg IS NOT NULL
            AND vcmodali IS NULL THEN
            RETURN 140039;   -- Datos incorrectos
         ELSIF vcmodali IS NOT NULL
               AND vcramo IS NULL THEN
            RETURN 140039;   -- Datos incorrectos
         END IF;

         -- se valida que los valores de los parametros pcmodali, pccolect y pctipseg
         -- introducidos como texto libre, sean validos
         -- El ramo, modalidad, colectivo y tipo de seguro deben existir
         BEGIN
            SELECT COUNT(*)   --cramo, cmodali, ccolect, ctipseg
              INTO vcont   --vcramo, vcmodali, vccolect, vctipseg
              FROM productos
             WHERE cramo = vcramo
               AND(cmodali = vcmodali
                   OR vcmodali IS NULL)
               AND(ctipseg = vctipseg
                   OR vctipseg IS NULL);

            -- NO SE VALIDA PUES DE MOMENTO SIEMPRE SERA NULL
            --   AND(ccolect = vccolect
            --       OR vccolect IS NULL)
            IF vcont = 0 THEN
               RETURN 140039;   -- Datos incorrectos
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 140039;   -- Datos incorrectos
         END;
      END IF;

      -- se a?ade esta select para identificar si el registro ya existe
      -- ya que tal y como esta definida la tabla no salta por la exception
      -- DUP_VAL_ON_INDEX y permite insetar 2 registros identicos
      SELECT COUNT(*)
        INTO vcont
        FROM agr_contratos
       WHERE scontra = pscontra
         AND((nversio IS NULL
              AND psversion IS NULL)
             OR(nversio = psversion
                AND psversion IS NOT NULL))
         AND cramo = vcramo
         AND((cmodali IS NULL
              AND vcmodali IS NULL)
             OR(cmodali = vcmodali
                AND vcmodali IS NOT NULL))
         AND((ctipseg IS NULL
              AND vctipseg IS NULL)
             OR(ctipseg = vctipseg
                AND vctipseg IS NOT NULL))
         AND((ccolect IS NULL
              AND vccolect IS NULL)
             OR(ccolect = vccolect
                AND vccolect IS NOT NULL))
         AND((cactivi IS NULL
              AND pcactivi IS NULL)
             OR(cactivi = pcactivi
                AND pcactivi IS NOT NULL))
         AND((cgarant IS NULL
              AND pcgarant IS NULL)
             OR(cgarant = pcgarant
                AND pcgarant IS NOT NULL));

      IF vcont <> 0 THEN
         RETURN 108959;   -- Este registro ya existe
      END IF;

      BEGIN
         INSERT INTO agr_contratos
                     (scontra, nversio, cramo, cmodali, ccolect, ctipseg, cactivi,
                      cgarant, ilimsub)
              VALUES (pscontra, psversion, vcramo, vcmodali, vccolect, vctipseg, pcactivi,
                      pcgarant, pilimsub);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            RETURN 108959;   -- Este registro ya existe
            -- de momento no se permite la actualizacion de un registro
/*
            UPDATE agr_contratos
               SET scontra = pscontra,
                   nversio = psversion
             WHERE cramo = vcramo
               AND((cmodali IS NULL
                    AND vcmodali IS NULL)
                   OR(cmodali = vcmodali
                      AND vcmodali IS NOT NULL))
               AND((ctipseg IS NULL
                    AND vctipseg IS NULL)
                   OR(ctipseg = vctipseg
                      AND vctipseg IS NOT NULL))
               AND((ccolect IS NULL
                    AND vccolect IS NULL)
                   OR(ccolect = vccolect
                      AND vccolect IS NOT NULL))
               AND((cactivi IS NULL
                    AND pcactivi IS NULL)
                   OR(cactivi = pcactivi
                      AND pcactivi IS NOT NULL))
               AND((cgarant IS NULL
                    AND pcgarant IS NULL)
                   OR(cgarant = pcgarant
                      AND pcgarant IS NOT NULL));
*/
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_agr_contratos', 1,
                     'par?metros- pscontra = ' || pscontra || '; psversion = ' || psversion
                     || '; pcramo = ' || pcramo || '; pcmodali = ' || pcmodali
                     || '; pccolect = ' || pccolect || '; pctipseg = ' || pctipseg
                     || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant
                     || '; pilimsub  = ' || pilimsub,
                     SQLERRM);
         RETURN 103820;
   END f_set_agr_contratos;

   -- BUG 28492 - FIN - DCT - 11/10/2013 - A?dir pilimsub

   /*************************************************************************
Funci?n que elimina una asociacion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcramo         agr_contratos.cramo%TYPE;
      vcmodali       agr_contratos.cmodali%TYPE;
      vccolect       agr_contratos.ccolect%TYPE;
      vctipseg       agr_contratos.ctipseg%TYPE;
   BEGIN
      vcramo := pcramo;
      vcmodali := pcmodali;
      vccolect := pccolect;
      vctipseg := pctipseg;

      IF psproduc IS NOT NULL THEN
         SELECT cramo, cmodali, ccolect, ctipseg
           INTO vcramo, vcmodali, vccolect, vctipseg
           FROM productos
          WHERE sproduc = psproduc;
      END IF;

      DELETE FROM agr_contratos
            WHERE scontra = pscontra
              AND((nversio IS NULL
                   AND psversion IS NULL)
                  OR(nversio = psversion
                     AND psversion IS NOT NULL))
              AND cramo = vcramo
              AND((cmodali IS NULL
                   AND vcmodali IS NULL)
                  OR(cmodali = vcmodali
                     AND vcmodali IS NOT NULL))
              AND((ctipseg IS NULL
                   AND vctipseg IS NULL)
                  OR(ctipseg = vctipseg
                     AND vctipseg IS NOT NULL))
              AND((ccolect IS NULL
                   AND vccolect IS NULL)
                  OR(ccolect = vccolect
                     AND vccolect IS NOT NULL))
              AND((cactivi IS NULL
                   AND pcactivi IS NULL)
                  OR(cactivi = pcactivi
                     AND pcactivi IS NOT NULL))
              AND((cgarant IS NULL
                   AND pcgarant IS NULL)
                  OR(cgarant = pcgarant
                     AND pcgarant IS NOT NULL));

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_agr_contratos', 1,
                     'pscontra = ' || pscontra || '; psversion = ' || psversion
                     || '; pcramo = ' || pcramo || '; pcmodali = ' || pcmodali
                     || '; pccolect = ' || pccolect || '; pctipseg = ' || pctipseg
                     || '; pcactivi = ' || pcactivi || '; pcgarant = ' || pcgarant,
                     SQLERRM);
         RETURN 103870;
   END f_del_agr_contratos;

   /*************************************************************************
   Funci?n que graba una asociacion de f?rmulas a garant?as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   -- 20/09/2011 - de momento no se crea esta funcion y se utiliza la funcion
   -- f_set_reaformula ya existente
/*
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF pscontra IS NULL THEN
         num_err := 101734;
         RETURN num_err;
      END IF;

      IF pnversion IS NULL THEN
         num_err := 9002128;
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO reaformula
                     (scontra, nversio, cgarant, ccampo, clave, sproduc)
              VALUES (pscontra, pnversion, pcgarant, pccampo, pclave, psproduc);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
*/
/*
            UPDATE reaformula
               SET tconagr = ptconagr
             WHERE sconagr = psconagr
               AND cidioma = pcidioma;
*/
/*
            NULL;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_reaformula', 1,
                     'par?metros- pscontra = ' || pscontra || '; pnversion = ' || pnversion
                     || '; psproduc = ' || psproduc || '; pcactivi = ' || pcactivi
                     || '; pcgarant = ' || pcgarant || '; pccampo = ' || pccampo
                     || '; pclave = ' || pclave,
                     SQLERRM);
         RETURN 103820;
   END f_set_reaformula;
*/
   /*************************************************************************
   Funci?n que elimina una asociacion de f?rmulas a garant?as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      DELETE FROM reaformula
            WHERE scontra = pscontra
              AND nversio = pnversion
              AND cgarant = pcgarant
              AND ccampo = pccampo
              AND clave = pclave
              AND((sproduc IS NULL
                   AND psproduc IS NULL)
                  OR(sproduc = psproduc
                     AND psproduc IS NOT NULL));

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_reaformula', 1,
                     'pscontra = ' || pscontra || '; pnversion = ' || pnversion
                     || '; psproduc = ' || psproduc || '; pcactivi = ' || pcactivi
                     || '; pcgarant = ' || pcgarant || '; pccampo = ' || pccampo
                     || '; pclave = ' || pclave,
                     SQLERRM);
         RETURN 103870;
   END f_del_reaformula;

   /*************************************************************************
   Funci?n que graba una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_contratosagr(psconagr IN NUMBER, pcidioma IN NUMBER, ptconagr IN VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      IF psconagr IS NULL THEN
         num_err := 101734;
         RETURN num_err;
      END IF;

      IF pcidioma IS NULL THEN
         num_err := 9002128;
         RETURN num_err;
      END IF;

      BEGIN
         INSERT INTO codicontratosagr
                     (sconagr)
              VALUES (psconagr);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            NULL;
      END;

      BEGIN
         INSERT INTO descontratosagr
                     (sconagr, cidioma, tconagr)
              VALUES (psconagr, pcidioma, ptconagr);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE descontratosagr
               SET tconagr = ptconagr
             WHERE sconagr = psconagr
               AND cidioma = pcidioma;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_contratosagr', 1,
                     'par?metros- psconagr = ' || psconagr || '; pcidioma = ' || pcidioma
                     || '; ptconagr = ' || ptconagr,
                     SQLERRM);
         RETURN 103820;
   END f_set_contratosagr;

   /*************************************************************************
   Funci?n que elimina una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_contratosagr(psconagr IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      DELETE FROM descontratosagr
            WHERE sconagr = psconagr
              AND(cidioma = pcidioma
                  OR pcidioma IS NULL);

      -- se borran todos los registros de la tabla descontratosagr y por lo tanto
      -- se elimina el registro de la tabla codicontratosagr
      IF pcidioma IS NULL THEN
         SELECT COUNT(1)
           INTO vcont
           FROM codicontratos
          WHERE sconagr = psconagr;

         IF vcont <> 0 THEN
            RETURN 9902461;   -- No se puede borrar la agrupaci?n. Existen contratos asociados.
         END IF;

         DELETE FROM codicontratosagr
               WHERE sconagr = psconagr;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_contratosagr', 2,
                     'psconagr = ' || psconagr || '; pcidioma = ' || pcidioma, SQLERRM);
         RETURN 103870;
   END f_del_contratosagr;

   /*************************************************************************
   Funci?n que devuelve el siguiente codigo de agrupacion de contrato
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_sconagr_next(psmaxconagr OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vsmaxconagr    NUMBER;
   BEGIN
      SELECT NVL(MAX(sconagr), 0) + 1
        INTO vsmaxconagr
        FROM codicontratosagr;

      psmaxconagr := vsmaxconagr;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_get_sconagr_next', 2, NULL, SQLERRM);
         RETURN 152993;   -- Error al recuperar la secuencia
   END f_get_sconagr_next;

   /*************************************************************************
   Funci?n que elimina un movimiento manual de la cuenta t?cnica del reaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_del_movctatecnica(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcconcep IN NUMBER,
      pnnumlin IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL)   --23830 DCT 27/12/2013
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      vcont          NUMBER := 0;
      v_max_fcierre  DATE;
   BEGIN
      SELECT MAX(fcierre)
        INTO v_max_fcierre
        FROM cierres
       WHERE cempres = pcempres
         AND ctipo IN(4, 15);

      SELECT COUNT(*)
        INTO vcont
        FROM movctatecnica
       WHERE cempres = pcempres
         AND ccompani = pccompani
         AND scontra = pscontra
         AND nversio = pnversio
         AND ctramo = pctramo
         AND fmovimi = pfcierre
         AND cconcep = pcconcep
         AND nnumlin = pnnumlin
         AND cestado <> 1   -- NO PENDIENTE
         AND(sproduc = psproduc
             OR NVL(sproduc, 0) = 0)
         AND(NVL(ctipmov, 0) = 0   -- Moviment autom?tic
             OR fmovimi < v_max_fcierre)
         AND(npoliza = pnpoliza
             AND ncertif = pncertif
             OR NVL(npoliza, 0) = NVL(pnpoliza, 0))
         AND(nsinies = pnsinies
             OR NVL(nsinies, 0) = NVL(pnsinies, 0))
         AND(ccompapr = pciaprop
             OR NVL(ccompapr, 0) = NVL(pciaprop, 0));

      IF vcont > 0 THEN
         num_err := 1000402;
      ELSE
         DELETE      movctatecnica
               WHERE cempres = pcempres
                 AND ccompani = pccompani
                 AND scontra = pscontra
                 AND nversio = pnversio
                 AND ctramo = pctramo
                 AND fmovimi = pfcierre
                 AND cconcep = pcconcep
                 AND nnumlin = pnnumlin
                 AND(sproduc = psproduc
                     OR NVL(sproduc, 0) = 0)
                 AND ctipmov = 1   -- Nom?s moviments manuals
                 AND cestado = 1   -- PENDIENTE
                 AND(npoliza = pnpoliza
                     AND ncertif = pncertif
                     OR NVL(npoliza, 0) = NVL(pnpoliza, 0))
                 AND(nsinies = pnsinies
                     OR NVL(nsinies, 0) = NVL(pnsinies, 0))
                 AND(ccompapr = pciaprop
                     OR NVL(ccompapr, 0) = NVL(pciaprop, 0));
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_movctatecnica', 2,
                     ' pcempres:' || pcempres || ' - psproduc:' || psproduc || ' - pccompani:'
                     || pccompani || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio
                     || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre
                     || ' - pcconcep:' || pcconcep || ' - pnnumlin:' || pnnumlin
                     || ' - pnpoliza:' || pnpoliza || ' - pncertif:' || pncertif
                     || ' - pnsinies:' || pnsinies || ' - pciaprop:' || pciaprop,
                     SQLERRM);
         RETURN 9903015;   -- Error, eliminado movimientos de cuentas t?cnica de reaseguro
   END f_del_movctatecnica;

   /*************************************************************************
    Funci?n que apunta en la tabla de liquidaci?n los importes pendientes de la cuenta t?cnica del reaseguro.
    *************************************************************************/-- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_rea(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcidioma IN NUMBER,
      psproces IN NUMBER,
      pcliquidar IN NUMBER DEFAULT 0,
      pciaprop IN NUMBER DEFAULT NULL,
      pultimoreg IN NUMBER DEFAULT 0)   --30203 KBR 16/07/2014
      RETURN NUMBER IS
      v_object       VARCHAR2(200) := 'PAC_REA.f_liquida_ctatec_rea';
      v_param        VARCHAR2(1000)
         := ' pcempres:' || pcempres || ' - psproduc:' || psproduc || ' - pccompani:'
            || pccompani || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio
            || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre || ' - pciaprop:'
            || pciaprop;
      vnumerr        NUMBER := 0;
      v_llinia       NUMBER := 0;
      v_ttexto1      VARCHAR2(1000);
      v_ttexto2      VARCHAR2(1000);
      v_ttexto3      VARCHAR2(1000);
      v_titulo       VARCHAR2(1000);
      v_spagrea      pagos_ctatec_rea.spagrea%TYPE;   --       v_spagrea      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iimport      movctatecnica.iimport%TYPE;   --       v_iimport      NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_fcambio      movctatecnica.fcambio%TYPE;   --       v_fcambio      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_itasa        NUMBER;
      v_cia          movctatecnica.ccompani%TYPE;   --       v_cia          NUMBER(3); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cestado      movctatecnica.cestado%TYPE;   --       v_cestado      NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_pasexec      NUMBER(5) := 0;
      v_cmultimon    parempresas.nvalpar%TYPE
                             := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncontab   parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_importe_mon  movctatecnica.iimport_moncon%TYPE;   --       v_importe_mon  NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iimp_montan  movctatecnica.iimport%TYPE;   --       v_iimp_montan  NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idifer       movctatecnica.iimport%TYPE;   --       v_idifer       NUMBER(15, 2); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_nnumlin      movctatecnica.nnumlin%TYPE;   --       v_nnumlin      NUMBER(4); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pnnumlin       movctatecnica.nnumlin%TYPE;   --       pnnumlin       NUMBER;   -- 22076/123753 AVT 26/09/2012 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      verror         NUMBER;
      vterminal      VARCHAR2(20);
      perror         VARCHAR2(2000);
      v_ctipopag     pagos_ctatec_rea.iimporte_moncon%TYPE;   --       v_ctipopag     NUMBER(1); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_descri       VARCHAR2(200);
      vproceslin     NUMBER;
      v_total_a_liquidar NUMBER;   --KBR 17/07/2014
      v_existe_pago_sproces NUMBER;   --KBR 21/07/2014
      v_broker       movctatecnica.ccorred%TYPE;   --KBR 04/09/2014

      -- 27911 AVT
      CURSOR principal IS
         SELECT   DECODE(pcliquidar, 1, m.ccompani, 0) cia,
                  SUM(DECODE(m.cdebhab, 1, iimport, -iimport)) iimport,
                  SUM(DECODE(m.cdebhab, 1, iimport_moncon, -iimport_moncon)) iimp_moncon
             FROM movctatecnica m, ctatecnica c, tipoctarea t
            WHERE m.cempres = pcempres
              AND(m.sproduc = psproduc
                  OR NVL(m.sproduc, 0) = 0)
              AND m.ccompani = c.ccompani
              AND m.scontra = c.scontra
              AND m.nversio = c.nversio
              AND m.ctramo = c.ctramo
              AND(m.sproduc = c.sproduc
                  OR c.sproduc = 0)
              AND c.ccorred = pccorred
              AND m.cestado = 1
              AND m.scontra = pscontra
              AND pccorred IS NOT NULL
              AND m.nversio = pnversio
              AND m.ctramo = pctramo
              AND m.fmovimi = pfcierre
              AND m.cconcep = t.cconcep
              AND t.ctipcta = 1
              AND t.cempres = pcempres   --KBR 20/11/2013
         GROUP BY DECODE(pcliquidar, 1, m.ccompani, 0)
         UNION ALL
         SELECT   m.ccompani cia, SUM(DECODE(m.cdebhab, 1, iimport, -iimport)) iimport,
                  SUM(DECODE(m.cdebhab, 1, iimport_moncon, -iimport_moncon)) iimp_moncon
             FROM movctatecnica m, tipoctarea t
            WHERE m.cempres = pcempres
              AND(m.sproduc = psproduc
                  OR NVL(sproduc, 0) = 0)
              AND m.ccompani = pccompani
              AND cestado = 1
              AND m.scontra = pscontra
              AND m.nversio = pnversio
              AND m.ctramo = pctramo
              AND m.fmovimi = pfcierre
              AND pccompani IS NOT NULL
              AND pccorred IS NULL   --23830 DCT (AVT) 27/12/2013
              AND m.cconcep = t.cconcep
              AND t.ctipcta = 1
              AND t.cempres = pcempres   --KBR 20/11/2013
         GROUP BY m.ccompani;
   BEGIN
      v_pasexec := 1;
      p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                  ' pcempres:' || pcempres || ' - psproduc:' || psproduc || ' - pccompani:'
                  || pccompani || ' - pscontra:' || pscontra || ' - pnversio:' || pnversio
                  || ' - pctramo:' || pctramo || ' - pfcierre:' || pfcierre || ' - pciaprop:'
                  || pciaprop,
                  SQLERRM);

      SELECT spagrea.NEXTVAL
        INTO v_spagrea
        FROM DUAL;

      v_pasexec := 2;

      IF pcliquidar = 0 THEN
         IF pccorred IS NOT NULL THEN
            --Liquidar por Corredor
            v_pasexec := 3;
            v_cia := NULL;
            v_broker := pccorred;
         ELSE
            --Liquidar por Cia Reaseguradora
            v_pasexec := 4;
            v_cia := pccompani;
            v_broker := NULL;
         -- Seleccionamos los datos pendientes de la cuenta t?cnica seg?n par?metros de entrada
         END IF;
      ELSE
         --Liquidamos por Cia Reaseguradora
         v_pasexec := 4;
         v_cia := pccompani;
         v_broker := pccorred;
      END IF;

-- 27911 AVT
      FOR reg IN principal LOOP
         --IF reg.cia <> 0 THEN
           -- v_cia := reg.cia;
         --END IF;
         v_iimport := reg.iimport;
         v_iimp_montan := reg.iimp_moncon;

         -- 27911 AVT fi
         IF NVL(v_iimport, 0) <> 0
            AND vnumerr = 0 THEN
            -- insertamos el Saldo
            IF v_cmultimon = 1 THEN
               v_pasexec := 5;
               v_fcambio := f_sysdate;
               vnumerr := pac_oper_monedas.f_datos_contraval(NULL, NULL, pscontra, v_fcambio,
                                                             3, v_itasa, v_fcambio);

               IF vnumerr = 0 THEN
                  v_importe_mon := f_round(NVL(v_iimport, 0) * v_itasa, v_cmoncontab);
               END IF;
            END IF;

            v_pasexec := 6;

            IF vnumerr = 0 THEN
               BEGIN
                  --KBR 23830 16/09/2013 Se agrega NVL
                  SELECT NVL(MAX(nnumlin), 0)
                    INTO v_nnumlin
                    FROM movctatecnica
                   WHERE ccompani = NVL(pccompani, reg.cia)
                     AND nversio = pnversio
                     AND scontra = pscontra
                     AND ctramo = pctramo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_nnumlin := 0;
               END;

               v_pasexec := 7;
               v_nnumlin := v_nnumlin + 1;

               IF vnumerr = 0 THEN
                  v_ttexto1 := f_axis_literales(104910, pcidioma);   -- Saldo
                  v_ttexto2 := f_axis_literales(9902071, pcidioma);   -- Liquidaci?n
                  v_ttexto3 := f_axis_literales(1000576, pcidioma);   -- Proceso
                  v_descri := v_ttexto1 || ' ' || v_ttexto2 || ':' || psproces || ', '
                              || v_ttexto3 || ':' || psproces;

                  BEGIN
                     INSERT INTO movctatecnica
                                 (ccompani, nversio, scontra, ctramo,
                                  nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
                                  cestado, sproces, iimport_moncon, fcambio, cempres,
                                  ctipmov, sproduc, fliquid, tdescri, ccompapr, spagrea,
                                  ccorred)
                          VALUES (NVL(pccompani, reg.cia), pnversio, pscontra, pctramo,
                                  v_nnumlin, pfcierre, pfcierre, 10, 1, v_iimport,
                                  0, psproces, v_importe_mon, v_fcambio, pcempres,
                                  1, psproduc, f_sysdate, v_descri, pciaprop, v_spagrea,
                                  v_broker);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
                        vnumerr := 104861;
                  END;

                  v_pasexec := 8;

                  IF vnumerr = 0 THEN
                     IF v_importe_mon > 0 THEN
                        v_ctipopag := 1;
                     ELSE
                        v_ctipopag := 2;
                     END IF;

-- insertamos en la nueva tabla de pagos liquidados del reaseguro
                     --KBR 21/07/2014 Evaluamos parametro de empresa LIQUIDACION_AGRUPADA 0-No, 1-Si
                     IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_CTATECREA_AGRUP'), 0) =
                                                                                              1 THEN
                        SELECT COUNT(*)
                          INTO v_existe_pago_sproces
                          FROM pagos_ctatec_rea
                         WHERE sproces = psproces;

                        IF v_existe_pago_sproces = 0 THEN
                           BEGIN
                              INSERT INTO pagos_ctatec_rea
                                          (spagrea, cempres, ccompani,
                                           ccorred, sproduc, iimporte, cestado, fliquida,
                                           cusuario, sproces, ctipopag, iimporte_moncon,
                                           fcambio)
                                   VALUES (v_spagrea, pcempres, NVL(pccompani, reg.cia),
                                           v_broker, psproduc, v_iimport, 1, f_sysdate,
                                           f_user, psproces, v_ctipopag, v_importe_mon,
                                           v_fcambio);
                           EXCEPTION
                              WHEN OTHERS THEN
                                 p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                                             SQLERRM);
                                 vnumerr := 9904133;
                           END;
                        ELSE
                           UPDATE pagos_ctatec_rea
                              SET iimporte = iimporte + v_iimport,
                                  iimporte_moncon = iimporte_moncon + v_importe_mon
                            WHERE sproces = psproces;
                        END IF;
                     ELSE
                        BEGIN
                           INSERT INTO pagos_ctatec_rea
                                       (spagrea, cempres, ccompani,
                                        ccorred, sproduc, iimporte, cestado, fliquida,
                                        cusuario, sproces, ctipopag, iimporte_moncon, fcambio)
                                VALUES (v_spagrea, pcempres, NVL(pccompani, reg.cia),
                                        v_broker, psproduc, v_iimport, 1, f_sysdate,
                                        f_user, psproces, v_ctipopag, v_importe_mon, v_fcambio);
                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                                          SQLERRM);
                              vnumerr := 9904133;
                        END;
                     END IF;

                     --FIN KBR 21/07/2014
                     v_cestado := 0;   -- LIQUIDADO

                     IF pccorred IS NOT NULL THEN
                        v_pasexec := 9;

                        --BUG 0023830 - INICIO - DCT - 20/12/2013 - A?dir en subselect ctatecnica la cempres y sproduc
                        -- actualizamos los pagos de la cuenta t?cnica como liquidados
                        UPDATE movctatecnica
                           SET cestado = v_cestado,   -- liquidado (DTV: 18)
                               fliquid = f_sysdate,
                               spagrea = v_spagrea
                         WHERE cempres = pcempres
                           AND(sproduc = psproduc
                               OR NVL(sproduc, 0) = 0)
                           AND ccompani IN(SELECT ccompani
                                             FROM ctatecnica c
                                            WHERE ccorred = pccorred
                                              AND c.scontra = pscontra
                                              AND c.nversio = pnversio
                                              AND c.ctramo = pctramo
                                              AND c.cempres = pcempres
                                              AND(c.sproduc = psproduc
                                                  OR NVL(c.sproduc, 0) = 0))
                           AND cestado = 1
                           AND cconcep < 50
                           AND scontra = pscontra
                           AND nversio = pnversio
                           AND ctramo = pctramo
                           AND fmovimi = pfcierre;
                     --BUG 0023830 - FIN - DCT - 20/12/2013 - A?dir en subselect ctatecnica la cempres y sproduc
                     ELSIF pccompani IS NOT NULL THEN
                        v_pasexec := 10;

                        -- actualizamos los pagos de la cuenta t?cnica como liquidados
                        UPDATE movctatecnica
                           SET cestado = v_cestado,   -- liquidado (DTV: 18)
                               fliquid = f_sysdate,
                               spagrea = v_spagrea
                         WHERE cempres = pcempres
                           AND(sproduc = psproduc
                               OR NVL(sproduc, 0) = 0)
                           AND ccompani = pccompani
                           AND cestado = 1
                           AND cconcep < 50
                           AND scontra = pscontra
                           AND nversio = pnversio
                           AND ctramo = pctramo
                           AND fmovimi = pfcierre;
                     ELSE
                        vnumerr := 1000165;   -- Campo obligatorio
                     END IF;
                  -- FI 23830 AVT 07/11/2012
                  END IF;
               ELSE
                  vnumerr := 102556;   -->> Error al calcular el saldo
               END IF;

               IF vnumerr = 0 THEN
                  v_pasexec := 11;
                  --------
                  -- apunte de diferencia de Perdidas / ganancias
                  v_idifer := v_iimp_montan - v_importe_mon;

                  IF v_idifer <> 0 THEN
                     v_nnumlin := v_nnumlin + 1;

                     -- 23830 AVT 08/11/2012 s'afegeix  l'actualitzaci? del spagrea tb pel concepte de Saldo generat
                     -- cestado = 4 no existeix pero es perque`no entri en cap proc?s fins que no es confirmi amb LCOL que fem amb aquest apunt
                     BEGIN
                        INSERT INTO movctatecnica
                                    (ccompani, nversio, scontra, ctramo,
                                     nnumlin, fmovimi, fefecto, cconcep, cdebhab, iimport,
                                     cestado, sproces, iimport_moncon, fcambio, cempres,
                                     ctipmov, sproduc, fliquid, ccompapr, spagrea, ccorred)
                             VALUES (NVL(pccompani, reg.cia), pnversio, pscontra, pctramo,
                                     v_nnumlin, pfcierre, pfcierre, 60, 1, v_idifer,
                                     4, psproces, v_idifer, v_fcambio, pcempres,
                                     1, psproduc, f_sysdate, pciaprop, v_spagrea, v_broker);
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                                       SQLERRM);
                           vnumerr := 104861;
                     END;
                  END IF;

                  --KBR 17/07/2014 Si desde la pantalla se indica que es el ¨²ltimo registro a liquidar se debe realizar el env¨ªo a JDE
                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'LIQ_CTATECREA_AGRUP'), 0) = 0 THEN
                     IF vnumerr = 0 THEN
                        -- 23830 AVT 08/10/2012 ajustar crides al JDE
                        IF NVL(pac_parametros.f_parempresa_n(pcempres, 'GESTIONA_LIQ_REACOA'),
                               0) = 1
                           AND v_ctipopag = 2 THEN
                           DECLARE
                              vtipopago      NUMBER := 8;   --tipo nuevo para Liquidacions ReasseguranÃ§a
                              vemitido       NUMBER;
                              vsinterf       NUMBER;
                           BEGIN
                              v_pasexec := 12;
                              vnumerr :=
                                 pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario,
                                                         vterminal);
                              vnumerr := pac_con.f_emision_pagorec(pcempres, 1, vtipopago,
                                                                   v_spagrea, 1, vterminal,
                                                                   vemitido, vsinterf, perror,
                                                                   f_user, NULL, NULL, NULL,
                                                                   1);

                              IF vnumerr <> 0
                                 OR TRIM(perror) IS NOT NULL THEN
                                 IF vnumerr = 0 THEN
                                    vnumerr := 151323;
                                 END IF;

                                 p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                                             perror || ' ' || vnumerr);
                                 vproceslin := f_proceslin(psproces, perror || ' ' || vnumerr,
                                                           0, v_llinia);
                              END IF;

                              --------
                              IF vnumerr = 0 THEN
                                 v_cestado := 2;   --En aprobación
                              ELSE
                                 v_cestado := 3;   --rechazado
                              END IF;
                           END;
                        ELSE
                           v_cestado := 0;   -- si no anem al JDE Liquidem directmanet
                        END IF;

                        UPDATE pagos_ctatec_rea
                           SET cestado = v_cestado
                         WHERE spagrea = v_spagrea;

                        v_pasexec := 13;

                        -- actualizamos los pagos de la cuenta t?cnica como liquidados
                        IF v_cestado = 0
                           OR v_cestado = 2 THEN
                           UPDATE movctatecnica
                              SET cestado = v_cestado   -- liquidado (DTV: 18)
                            WHERE spagrea = v_spagrea;
                        END IF;

                        IF v_cestado = 3 THEN
                           UPDATE movctatecnica
                              SET cestado = v_cestado
                            WHERE spagrea = v_spagrea
                              AND cconcep = 10;

                           UPDATE movctatecnica
                              SET cestado = 1
                            WHERE spagrea = v_spagrea
                              AND cconcep <> 10;
                        END IF;

                        -- JAM 23830-161685
                        vnumerr := pac_rea.f_set_reten_liquida(pccompani, pnversio, pscontra,
                                                               pctramo, NULL, pccorred,
                                                               pcempres, psproduc, pfcierre, 1,
                                                               4);
                     -- Fin JAM 23830-161685
                     END IF;
                  ELSE
                     IF pultimoreg = 1 THEN
                        IF vnumerr = 0 THEN
                           SELECT NVL(SUM(iimporte_moncon), 0)
                             INTO v_total_a_liquidar
                             FROM pagos_ctatec_rea
                            WHERE sproces = psproces
                              AND cempres = pcempres
                              AND TRUNC(fliquida) = TRUNC(f_sysdate);

                           IF v_total_a_liquidar <> 0 THEN
                              IF v_total_a_liquidar > 0 THEN
                                 v_ctipopag := 1;
                              ELSE
                                 v_ctipopag := 2;
                              END IF;

                              -- 23830 AVT 08/10/2012 ajustar crides al JDE
                              IF NVL(pac_parametros.f_parempresa_n(pcempres,
                                                                   'GESTIONA_LIQ_REACOA'),
                                     0) = 1
                                 AND v_ctipopag = 2 THEN
                                 DECLARE
                                    vtipopago      NUMBER := 8;   --tipo nuevo para Liquidacions Reasseguran?a
                                    vemitido       NUMBER;
                                    vsinterf       NUMBER;
                                 BEGIN
                                    v_pasexec := 12;
                                    vnumerr :=
                                       pac_user.f_get_terminal
                                                              (pac_md_common.f_get_cxtusuario,
                                                               vterminal);
                                    vnumerr :=
                                       pac_con.f_emision_pagorec
                                          (pcempres, 1, vtipopago, psproces,   --v_spagrea, KBR: 17/07/2014 se cambia por sproces
                                           1, vterminal, vemitido, vsinterf, perror, f_user,
                                           NULL, NULL, NULL, 1);

                                    IF vnumerr <> 0
                                       OR TRIM(perror) IS NOT NULL THEN
                                       IF vnumerr = 0 THEN
                                          vnumerr := 151323;
                                       END IF;

                                       p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                                                   v_param, perror || ' ' || vnumerr);
                                       vproceslin :=
                                          f_proceslin(psproces, perror || ' ' || vnumerr, 0,
                                                      v_llinia);
                                    END IF;

                                    --------
                                    IF vnumerr = 0 THEN
                                       v_cestado := 2;   --En aprobacion
                                    ELSE
                                       v_cestado := 3;   --rechazado
                                    END IF;
                                 END;
                              ELSE
                                 v_cestado := 0;   -- si no anem al JDE Liquidem directmanet
                              END IF;

                              UPDATE pagos_ctatec_rea
                                 SET cestado = v_cestado
                               WHERE sproces = psproces;   --spagrea = v_spagrea; KBR 17/07/2014

                              v_pasexec := 13;

                              -- actualizamos los pagos de la cuenta t?cnica como liquidados
                              IF v_cestado = 0
                                 OR v_cestado = 2 THEN
                                 UPDATE movctatecnica
                                    SET cestado = v_cestado   -- liquidado (DTV: 18)
                                  WHERE sproces = psproces;   --spagrea = v_spagrea; KBR 17/07/2014

                                 UPDATE movctatecnica
                                    SET cestado = v_cestado
                                  WHERE spagrea IN(
                                           SELECT spagrea
                                             FROM movctatecnica m2
                                            WHERE m2.sproces = psproces
                                              AND cempres = pcempres
                                              AND TRUNC(fliquid) = TRUNC(f_sysdate))   --spagrea = v_spagrea; KBR 17/07/2014
                                    AND cconcep <> 10;
                              END IF;

                              IF v_cestado = 3 THEN
                                 UPDATE movctatecnica
                                    SET cestado = v_cestado
                                  WHERE sproces = psproces   --spagrea = v_spagrea; KBR 17/07/2014
                                    AND cconcep = 10;

                                 UPDATE movctatecnica
                                    SET cestado = 1
                                  WHERE spagrea IN(
                                           SELECT spagrea
                                             FROM movctatecnica m2
                                            WHERE m2.sproces = psproces
                                              AND cempres = pcempres
                                              AND TRUNC(fliquid) = TRUNC(f_sysdate))   --spagrea = v_spagrea; KBR 17/07/2014
                                    AND cconcep <> 10;
                              END IF;

                              -- JAM 23830-161685
                              vnumerr := pac_rea.f_set_reten_liquida(pccompani, pnversio,
                                                                     pscontra, pctramo, NULL,
                                                                     pccorred, pcempres,
                                                                     psproduc, pfcierre, 1, 4);
                           -- Fin JAM 23830-161685
                           END IF;
                        END IF;
                     END IF;   --FIN KBR 17/07/2014
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      v_pasexec := 16;
      p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, perror || ' ' || vnumerr);
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9904133;
   END f_liquida_ctatec_rea;

    /*************************************************************************
      Funci?n que insertar? o modificar? un movimiento de cuenta t?cnica en funci?n del pmodo

      Parametros:
      pccompani        C?digo de compa?ia
      pnversio         N?mero versi?n contrato reas.
      pscontra         C?digo de contrato reaseguro
      pctramo          C?digo del tramo
      pnnumlin         N?mero de l?nea
      pfmovimi         Fecha generaci?n movimiento
      pfefecto         Fecha de efecto del movimiento
      pcconcep         Concepto del movimiento
      pcdebhab         Debe o Haber
      piimport         Importe del movimiento
      pcestado         Estado del movimiento
      psproces         Identificador de proceso
      pscesrea         Secuencia de cesi?n reaseguro
      piimport_moncon  Importe del movimiento en la moneda de la contabilidad
      pfcambio         Fecha empleada para el c?lculo de los contravalores
      pcempres         C?digo de Empresa
      pcmanual         Tipo de movimiento manual-1 o autom?tica-0
      pdescrip         Descripci?n
      pdocumen         Documento
      pmodo            Modo 0-Modificaci?n 1-Alta 2-Consulta
      return                : 0.-    OK
                              1.-    KO

   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_movctatecnica(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnnumlin IN NUMBER,
      pfmovimi IN DATE,
      pfefecto IN DATE,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pcestado IN NUMBER,
      psproces IN NUMBER,
      pscesrea IN NUMBER,
      piimport_moncon IN NUMBER,
      pfcambio IN DATE,
      pcempres IN NUMBER,
      pdescrip IN VARCHAR2,
      pdocumen IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN NUMBER,
      psidepag IN NUMBER DEFAULT NULL,
      pciaprop IN NUMBER DEFAULT NULL)   --23830 DCT /AVT 27/12/2013
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_REA.f_set_movctatecnica';
      v_param        VARCHAR2(800)
         := 'params : pccompani : ' || pccompani || ', pnversio : ' || pnversio
            || ', pscontra : ' || pscontra || ' , pctramo : ' || pctramo || ', pnnumlin : '
            || pnnumlin || ', pfmovimi : ' || pfmovimi || ', pfefecto : ' || pfefecto
            || ', pcconcep : ' || pcconcep || ' , pcdebhab : ' || pcdebhab || ', piimport :'
            || piimport || ', pcestado : ' || pcestado || ', psproces : ' || psproces
            || ', pscesrea : ' || pscesrea || ', piimport_moncon : ' || piimport_moncon
            || ', pfcambio : ' || pfcambio || ', pcempres : ' || pcempres || ', pdescrip : '
            || pdescrip || ', pdocumen : ' || pdocumen || ' - pnpoliza:' || pnpoliza
            || ' - pncertif:' || pncertif || ' - pnsinies:' || pnsinies || ' psproduc:'
            || psproduc || ' pmodo:' || pmodo || ' pciaprop:' || pciaprop;
      v_pasexec      NUMBER(5) := 0;
      v_nnumlin      movctatecnica.nnumlin%TYPE;   --       v_nnumlin      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_fcambio      DATE;   --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_error        NUMBER := 0;
      v_ctipmov      NUMBER;
      v_itasa        NUMBER;
      v_cmultimon    parempresas.nvalpar%TYPE
                             := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_cmoncontab   parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_importe_mon  movctatecnica.iimport%TYPE;   --       v_importe_mon  NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cestado      movctatecnica.cestado%TYPE;
      v_cdebhab      movctatecnica.cdebhab%TYPE;   --       v_cdebhab      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_iimport      movctatecnica.iimport%TYPE;   --       v_iimport      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vnpoliza       seguros.npoliza%TYPE;
      vncertif       seguros.ncertif%TYPE;
      vnpoliza_aux   seguros.npoliza%TYPE;
      vncertif_aux   seguros.ncertif%TYPE;
      vdescrip       movctatecnica.tdescri%TYPE;
      k_idiomaaxis CONSTANT seguros.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   BEGIN
      IF pmodo = 1 THEN   --Inserci?n de registros
         v_fcambio := pfmovimi;
      ELSE
         IF pfcambio IS NULL THEN
            v_fcambio := pfmovimi;
         ELSE
            v_fcambio := pfcambio;
         END IF;
      END IF;

      v_pasexec := 1;

      --No se puede imputar a meses cerrados (4 Cierre reaseguro)(cvalor 167 tipos de cierre)
      IF pfefecto IS NOT NULL
         AND TRUNC(pfefecto) < NVL(pac_cierres.f_fecha_ultcierre(pcempres, 4), v_fcambio) THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 107855;
      END IF;

      v_pasexec := 2;

      IF v_cmultimon = 1 THEN
         v_error := pac_oper_monedas.f_datos_contraval(NULL, NULL, pscontra, v_fcambio, 3,
                                                       v_itasa, v_fcambio);

         IF v_error <> 0 THEN
            p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
            RETURN v_error;
         END IF;

         v_importe_mon := NVL(piimport_moncon,
                              f_round(NVL(piimport, 0) * v_itasa, v_cmoncontab));
      END IF;

      v_pasexec := 4;

      --KBR 19/09/2013 Si el concepto est?relacionado con Siniestros deber?informar el nro de siniestro obligatoriamente
      --Conceptos:
      -- 5 : Siniestros
      -- 17: Siniestro al contado
      -- 25: Reserva de Siniestros
      IF (pcconcep = 5
          OR pcconcep = 17
          OR pcconcep = 25)
         AND(pnsinies IS NULL
             OR pnsinies = 0) THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9001940;
      END IF;

      --KBR 19/09/2013 Si el concepto es Prima (1) deber?informar el nro de p?iza obligatoriamente
      IF pcconcep = 1
         AND NVL(pnpoliza, 0) = 0 THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9900973;
      END IF;

      v_pasexec := 5;
      --BUG 23830/151936 - INICIO - DCT - 04/09/2013
      vnpoliza := pnpoliza;
      vncertif := pncertif;

      IF NVL(pnsinies, 0) <> 0 THEN
         v_error := f_get_npoliza(pnsinies, vnpoliza_aux, vncertif_aux);
      END IF;

      IF v_error <> 0 THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN v_error;
      END IF;

      --Si no s? iguales se reemplza por la p?iza y certificado correctos
      IF vnpoliza_aux <> NVL(vnpoliza, 0)
         OR vncertif_aux <> NVL(vncertif, 0) THEN
         vnpoliza := vnpoliza_aux;
         vncertif := vncertif_aux;
      END IF;

      vdescrip := pdescrip;

      IF pdescrip IS NULL
         AND pcconcep IS NOT NULL THEN
         vdescrip := ff_desvalorfijo(124, k_idiomaaxis, pcconcep);
      END IF;

      --INICIO - 27/09/2013 - RCL - BUG 23830/153904
      IF pcconcep IS NOT NULL
         AND pac_md_common.f_get_cxtempresa() = 12 THEN
         IF pcconcep = 5 THEN
            IF pnsinies IS NULL THEN
               RETURN 9901380;   --Valor erroneo del siniestro
            ELSE
               IF psidepag IS NULL THEN
                  RETURN 9906034;   --El identificador de pago es obligatorio
               END IF;
            END IF;
         ELSIF pcconcep = 1 THEN
            IF vnpoliza IS NULL THEN
               RETURN 9900973;   --El numero de poliza no existe.
            ELSE
               --Comprobamos que el numero de poliza exista en SEGUROS.
               SELECT COUNT(1)
                 INTO v_error
                 FROM seguros s
                WHERE s.cempres = pac_md_common.f_get_cxtempresa
                  AND s.npoliza = vnpoliza
                  AND s.ncertif = NVL(vncertif, s.ncertif);

               IF v_error = 0 THEN
                  RETURN 9900973;   --El numero de poliza no existe.
               ELSE
                  --Comprobamos que el numero de poliza este asociado al contrato.
                  SELECT COUNT(1)
                    INTO v_error
                    FROM cesionesrea cr, seguros ss
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND cr.sseguro = ss.sseguro
                     AND npoliza = vnpoliza;

                  IF v_error = 0 THEN
                     RETURN 9906036;   --El numero de poliza no es valido para este contrato
                  END IF;
               END IF;

               v_error := 0;
            END IF;
         END IF;
      END IF;

      --FIN - 27/09/2013 - RCL - BUG 23830/153904

      --BUG 23830/151936 - FIN - DCT - 04/09/2013
      IF pmodo = 0 THEN   --Modificaci?n de registros
         v_pasexec := 4;

         BEGIN
            SELECT NVL(ctipmov, 0), cestado, cdebhab, iimport
              INTO v_ctipmov, v_cestado, v_cdebhab, v_iimport
              FROM movctatecnica
             WHERE ccompani = pccompani
               AND nversio = pnversio
               AND scontra = pscontra
               AND ctramo = pctramo
               AND nnumlin = pnnumlin
               AND NVL(ccompapr, 0) = pciaprop   -- AVT 03/01/204 pciaprop
               AND(sproduc = psproduc
                   OR NVL(sproduc, 0) = 0);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               v_error := 104863;
         END;

         v_pasexec := 5;

         IF v_error = 0 THEN
            IF (v_cdebhab = 2
                AND v_iimport < 0)
               OR(v_cdebhab = 1
                  AND v_iimport > 0) THEN
               -- SI PERMET LIQUIDAR
               IF pcestado NOT IN(1, 3, 0) THEN
                  v_error := 110300;   -- Cambio de estado no permitido
               END IF;
            ELSE
               IF v_cestado NOT IN(1, 3)
                  OR pcestado NOT IN(1, 3) THEN
                  v_error := 110300;   -- Cambio de estado no permitido
               END IF;
            END IF;

            IF v_error = 0 THEN
               IF v_ctipmov = 1 THEN   -- Movimiento manual
                  v_pasexec := 6;

                  BEGIN
                     UPDATE movctatecnica
                        SET fmovimi = pfmovimi,   -- 'to_date(''' || TO_CHAR(pfcierre, 'dd/mm/yyyy')  || ''',''dd/mm/yyyy'')' ????
                            fefecto = NVL(pfefecto, pfmovimi),
                            cconcep = pcconcep,
                            cdebhab = pcdebhab,
                            iimport = piimport,
                            cestado = pcestado,
                            sproces = NULL,
                            scesrea = pscesrea,
                            iimport_moncon = v_importe_mon,
                            fcambio = v_fcambio,
                            cempres = pcempres,
                            tdescri = vdescrip,
                            tdocume = pdocumen,
                            npoliza = vnpoliza,
                            ncertif = NVL(vncertif, 0),
                            nsinies = pnsinies,
                            sidepag = psidepag   --27/09/2013 - RCL - BUG 23830/153904
                      WHERE ccompani = pccompani
                        AND nversio = pnversio
                        AND scontra = pscontra
                        AND ctramo = pctramo
                        AND nnumlin = pnnumlin
                        AND(sproduc = psproduc
                            OR NVL(sproduc, 0) = 0)
                        AND NVL(ccompapr, 0) = pciaprop   -- AVT 03/01/204 pciaprop
                        AND ctipmov = 1   -- Movimiento manual
                        AND cestado = 1;   -- Pendiente
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
                        v_error := 104863;
                  END;
               ELSE   -- Movimiento autom?tico: s?lo se puede Bloquear o a?adir Descripci?n y/o deocumento
                  v_pasexec := 7;

                  BEGIN
                     UPDATE movctatecnica
                        SET cestado = pcestado,
                            tdescri = vdescrip,
                            tdocume = pdocumen,
                            fcambio = v_fcambio,
                            npoliza = vnpoliza,
                            ncertif = NVL(vncertif, 0),
                            nsinies = pnsinies
                      WHERE ccompani = pccompani
                        AND nversio = pnversio
                        AND scontra = pscontra
                        AND ctramo = pctramo
                        AND nnumlin = pnnumlin
                        AND NVL(ccompapr, 0) = pciaprop   -- AVT 03/01/204 pciaprop
                        AND(sproduc = psproduc
                            OR NVL(sproduc, 0) = 0);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
                        v_error := 104863;
                  END;
               END IF;
            END IF;

            v_pasexec := 8;

            IF v_error <> 0 THEN
               RETURN v_error;
            END IF;
         END IF;
      ELSIF pmodo = 1 THEN   --Inserci?n de registros
         v_pasexec := 9;

         IF pcestado NOT IN(1, 3) THEN
            v_error := 110300;   -- Cambio de estado no permitido
         END IF;

         BEGIN
            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO v_nnumlin
              FROM movctatecnica
             WHERE ccompani = pccompani
               AND nversio = pnversio
               AND scontra = pscontra
               AND ctramo = pctramo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_nnumlin := 1;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               v_error := 104863;
         END;

         v_pasexec := 10;

         BEGIN
            INSERT INTO movctatecnica
                        (ccompani, nversio, scontra, ctramo, nnumlin, fmovimi,
                         fefecto, cconcep, cdebhab, iimport, cestado, sproces,
                         scesrea, iimport_moncon, fcambio, cempres, ctipmov, tdescri,
                         tdocume, npoliza, ncertif, nsinies, sproduc,
                         sidepag, ccompapr)   -- AVT 03/01/204 pciaprop
                 VALUES (pccompani, pnversio, pscontra, pctramo, v_nnumlin, pfmovimi,
                         NVL(pfefecto, pfmovimi), pcconcep, pcdebhab, piimport, 1,   -- sempres han de neixer "Pendents"........
                                                                                  NULL,
                         pscesrea, v_importe_mon, v_fcambio, pcempres, 1, vdescrip,
                         pdocumen, vnpoliza, NVL(vncertif, 0), pnsinies, NVL(psproduc, 0),
                         psidepag, NVL(pciaprop, 0));   -- AVT 03/01/204 pciaprop
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               v_error := 104861;
         END;

         v_pasexec := 11;

         IF v_error <> 0 THEN
            RETURN v_error;
         END IF;
      END IF;

      v_pasexec := 12;
      RETURN v_error;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 9903018;   -- Error grabando movimientos de cuentas t?cnicas de reaseguro
   END f_set_movctatecnica;

/***************************************************************************
  Funci?n que retiene un movimiento de cuenta t?cnica para que no se liquide
  o li canvia l'estat (nom? no modifica els liquidats)
****************************************************************************/
-- Bug 22076 - AVT - 21/06/2012 - se crea la funcion
   FUNCTION f_set_reten_liquida(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnnumlin IN NUMBER,
      pccorred IN NUMBER DEFAULT NULL,
      pcempres IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pfcierre IN DATE DEFAULT NULL,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_REA.f_set_reten_liquida';
      v_param        VARCHAR2(500)
         := 'params : pccompani : ' || pccompani || ', pnversio : ' || pnversio
            || ', pscontra : ' || pscontra || ' , pctramo : ' || pctramo || ', pnnumlin : '
            || pnnumlin;
      v_pasexec      NUMBER(5) := 0;
   BEGIN
      IF pnnumlin IS NOT NULL THEN
         UPDATE movctatecnica
            SET cestado = pestadonew
          --3   -- VF: 800106 - Rebutjada (nom?s podem modificar registres de 1-Pendent a 3-Rebutjat i de 3 a 1
         WHERE  ccompani = pccompani
            AND nversio = pnversio
            AND scontra = pscontra
            AND ctramo = pctramo
            AND nnumlin = pnnumlin
            AND cestado = pestadoold;
      ELSE
         IF pccorred IS NOT NULL THEN
            UPDATE movctatecnica
               SET cestado = pestadonew
             WHERE cempres = pcempres
               AND(sproduc = psproduc
                   OR NVL(sproduc, 0) = 0)
               AND ccompani IN(SELECT ccompani
                                 FROM ctatecnica c
                                WHERE c.ccorred = pccorred
                                  AND c.scontra = pscontra
                                  AND c.nversio = pnversio
                                  AND c.ctramo = pctramo
                                  AND c.cempres = pcempres
                                  AND(sproduc = psproduc
                                      OR NVL(sproduc, 0) = 0))
               AND cestado = pestadoold
               AND cconcep < 50
               AND scontra = pscontra
               AND nversio = pnversio
               AND ctramo = pctramo
               AND fmovimi = pfcierre;
         ELSIF pccompani IS NOT NULL THEN
            UPDATE movctatecnica
               SET cestado = pestadonew
             WHERE cempres = pcempres
               AND(sproduc = psproduc
                   OR NVL(sproduc, 0) = 0)
               AND ccompani = pccompani
               AND cestado = pestadoold
               AND cconcep < 50
               AND scontra = pscontra
               AND nversio = pnversio
               AND ctramo = pctramo
               AND fmovimi = pfcierre;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 105234;
   END f_set_reten_liquida;

   /*******************************************************************************
                                                                                                                                                                                                                                                   FUNCION F_INICIALIZA_CARTERA
    Esta funci?n devuelve el sproces con el que se realizar? la liquidaci? del Reaseguro,
    para ello llamar? a la funci?n de f_procesini.
   Par?metros
    Entrada :
       Pfperini  DATE     : Fecha
       Pcempres  NUMBER   : Empresa
       Ptexto    VARCHAR2 :
    Salida :
       Psproces  NUMBER  : Numero proceso de cartera.
   Retorna :NUMBER con el n?mero de proceso
   *********************************************************************************/
   FUNCTION f_inicializa_liquida_rea(
      pfperini IN DATE,
      pcempres IN NUMBER,
      ptexto IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'Pfperini=' || pfperini || ' Pcempres=' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_REA.f_inicializa_liquida_rea';
      v_titulo       VARCHAR2(200);
      num_err        NUMBER;
      pnnumlin       movctatecnica.nnumlin%TYPE;   --       pnnumlin       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      pcerror        NUMBER;
      conta_err      NUMBER;
      vtexto         VARCHAR2(2000);
   BEGIN
      -- Control parametros entrada
      IF pfperini IS NULL
         OR pcempres IS NULL
         OR pcidioma IS NULL THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                     ' Faltan parametros por informar: ' || vparam, SQLERRM);
         RETURN 140974;   --Faltan parametros por informar
      END IF;

      v_titulo := 'Liquida Reaseguro - ' || vparam;
      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err := f_procesini(f_user, pcempres, ptexto, v_titulo, psproces);

      IF num_err <> 0 THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         vtexto := f_axis_literales(num_err, pcidioma);
         pnnumlin := NULL;
         num_err := f_proceslin(psproces, vtexto, 0, pnnumlin);
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9904134;
   END f_inicializa_liquida_rea;

   /*****************************************************************************
    La nueva funci? recibir?como par?etro la garant? que se est?contratando y producto,
    con ellos se obtendr? todas las que est? dentro del mismo grupo (tabla: PARGARANPRO),
    del grupo de garant?s se verificar?por cada una de ellas si est?contratada y
    si su capital es mayor al de la garant? que recibimos por par?etro.
    En caso que ninguna de las garant?s contratadas tenga un capital mayor retornar?su capital en caso contrario retornar?0 (cero)
    *********************************************************************************/
   FUNCTION f_max_gar_reaseg_agrup(
      sesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_gar_ppal IN NUMBER,
      p_sproduc IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_gar_rel IS
         SELECT cgarant
           FROM pargaranpro
          WHERE cpargar = 'AGRGARREA'
            AND cgarant <> p_gar_ppal
            AND sproduc = p_sproduc
            AND cvalpar = (SELECT cvalpar
                             FROM pargaranpro
                            WHERE cpargar = 'AGRGARREA'
                              AND cgarant = p_gar_ppal
                              AND sproduc = p_sproduc);

      v_cap_gar      NUMBER;
      v_cap_gar_aux  NUMBER;
      v_norden_gar   NUMBER;
      v_norden_gar_aux NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'sesion=' || sesion || ' p_sseguro  =' || p_sseguro || ' p_nriesgo = ' || p_nriesgo
            || ' p_nmovimi = ' || p_nmovimi || ' p_gar_ppal = ' || p_gar_ppal
            || '  p_sproduc = ' || p_sproduc;
      vobject        VARCHAR2(200) := 'PAC_REA.f_max_gar_reaseg_agrup';
   BEGIN
      BEGIN
         SELECT icapital, norden
           INTO v_cap_gar, v_norden_gar
           FROM garanseg
          WHERE sseguro = p_sseguro
            AND nriesgo = p_nriesgo
            AND nmovimi = p_nmovimi
            AND cgarant = p_gar_ppal;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            SELECT icapital, norden
              INTO v_cap_gar, v_norden_gar
              FROM estgaranseg
             WHERE sseguro = p_sseguro
               AND nriesgo = p_nriesgo
               AND nmovimi = p_nmovimi
               AND cgarant = p_gar_ppal;
      END;

      FOR i IN c_gar_rel LOOP
         --Si est?contratada
         BEGIN
            SELECT icapital, norden
              INTO v_cap_gar_aux, v_norden_gar_aux
              FROM garanseg
             WHERE sseguro = p_sseguro
               AND nriesgo = p_nriesgo
               AND nmovimi = p_nmovimi
               AND cgarant = i.cgarant;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                  SELECT icapital, norden
                    INTO v_cap_gar_aux, v_norden_gar_aux   --AVT 29/01/2014
                    FROM estgaranseg
                   WHERE sseguro = p_sseguro
                     AND nriesgo = p_nriesgo
                     AND nmovimi = p_nmovimi
                     AND cgarant = i.cgarant;   --AVT 29/01/2014
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN   --AVT 30/01/2014
                     RETURN v_cap_gar;
               END;
         END;

         --Si el capital de la garantia auxiliar es mayor al de la garantia tratada retornamos 0
         IF v_cap_gar_aux > v_cap_gar THEN
            RETURN 0;
         --Si los capitales son iguales y el orden de la garant? es mayor retornamos 0
         ELSIF v_cap_gar_aux = v_cap_gar
               AND v_norden_gar > v_norden_gar_aux THEN
            RETURN 0;
         END IF;
      END LOOP;

      RETURN v_cap_gar;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 151395;   --Error al obtener el importe capital
   END;

   -- Bug 26444 - ETM - 31/07/2012 - se crea la funcion -INI
   FUNCTION f_borrar_movprevio(pcempres IN NUMBER, pnid IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_REA.f_borrar_movprevio';
      v_param        VARCHAR2(500)
                      := 'params : psproces :  pcempres : ' || pcempres || ', pnid : ' || pnid;
      v_pasexec      NUMBER(5) := 0;
   BEGIN
      DELETE      mov_manual_prev
            WHERE nid = pnid
              AND cempres = pcempres;

      v_pasexec := 1;

      DELETE      pagosreaxl_aux
            WHERE nid = pnid;

      v_pasexec := 2;

      DELETE      liquidareaxl_aux
            WHERE nid = pnid;

      v_pasexec := 3;

      DELETE      movctaaux
            WHERE nid = pnid
              AND cempres = pcempres;

      v_pasexec := 4;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 140999;   --Error no controlado
   END f_borrar_movprevio;

   FUNCTION f_valida_capacidad_contrato(
      pcempres IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      ptdescrip IN VARCHAR2,
      pnidentif IN VARCHAR2,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcevento IN VARCHAR2,
      pcgarant IN NUMBER,
      pnidout IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'pac_rea.f_valida_capacidad_contrato';
      v_traza        NUMBER(5) := 0;
      vnumerr        NUMBER := 0;
      v_capacidad    NUMBER := 0;
      v_ipagos_prev  NUMBER := 0;
      v_ipagos       NUMBER := 0;
      v_repos        NUMBER := 0;
      v_icap_repos   NUMBER(14, 3) := 0;
      v_ipagos_reins NUMBER := 0;
      v_ipagos_reins_prev NUMBER := 0;
   BEGIN
      -- Validaci? de la capacidad del Contrato
      IF pcconcep IN(5, 23) THEN
         IF pcconcep = 5 THEN   -- Para pago de siniestros
            -- Obtener capital del TRAMO
            BEGIN
               SELECT NVL(itottra, 0)
                 INTO v_capacidad
                 FROM tramos
                WHERE scontra = pscontra
                  AND nversio = pnversio
                  AND ctramo = pctramo;

               IF v_capacidad = 0 THEN
                  SELECT NVL(icapaci, 0)
                    INTO v_capacidad
                    FROM contratos
                   WHERE scontra = pscontra
                     AND nversio = pnversio;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  SELECT NVL(icapaci, 0)
                    INTO v_capacidad
                    FROM contratos
                   WHERE scontra = pscontra
                     AND nversio = pnversio;
            END;

            -- Obtener valor de los pagos realizados(previos)
            BEGIN
               SELECT NVL(SUM(iliqrea), 0)
                 INTO v_ipagos_prev
                 FROM pagosreaxl
                WHERE scontra = pscontra
                  AND nversio = pnversio
                  AND ctramo = pctramo
                  AND fcierre < pfcierre
                  AND NVL(nsinies, 0) = NVL(NVL(pnsinies, nsinies), 0)
                  AND NVL(cevento, 0) = NVL(NVL(pcevento, cevento), 0)
                  AND cestliq = 1;   -- s?o estado liquidado
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ipagos_prev := 0;
            END;

            -- Obtener valor de los pagos (para el cierre)
            BEGIN
               SELECT NVL(SUM(iimport), 0)
                 INTO v_ipagos
                 FROM movctaaux
                WHERE scontra = pscontra
                  AND nversio = pnversio
                  AND ctramo = pctramo
                  AND fmovimi = pfcierre
                  AND NVL(nsinies, 0) = NVL(NVL(pnsinies, nsinies), 0)
                  AND NVL(cevento, 0) = NVL(NVL(pcevento, cevento), 0)
                  AND cconcep = 5;   -- Siniestros
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_ipagos := 0;
            END;

            -- Evaluar la capacidad del contrato
            IF ((v_capacidad -(v_ipagos_prev + v_ipagos)) < piimport) THEN
               p_tab_error(f_sysdate, f_user, v_object, v_traza,
                           'Error validando capacidad de Pagos de Siniestros',
                           'La capacidad del Contrato/Tramo es menor a los pagos realizados');
               RETURN 9906335;
            END IF;
         ELSE
            IF pcconcep = 23 THEN   -- Para pago de reinstalamiento
               -- Verificar que el CONTRATO/TRAMO posee reinstalamiento
               SELECT COUNT(*)
                 INTO v_repos
                 FROM reposiciones_det
                WHERE ccodigo = (SELECT crepos
                                   FROM tramos
                                  WHERE scontra = pscontra
                                    AND nversio = pnversio
                                    AND ctramo = pctramo);

               IF v_repos = 0 THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_traza, 'Error: Reposiciones XL',
                              'No existen reposiciones para el Contrato/Tramo');
                  RETURN 9906336;
               END IF;

               -- Obtener el valor de las capacidades de TODOS los reinstalamientos para el CONTRATO/TRAMO
               SELECT SUM(icapacidad)
                 INTO v_icap_repos
                 FROM reposiciones_det
                WHERE ccodigo = (SELECT crepos
                                   FROM tramos
                                  WHERE scontra = pscontra
                                    AND nversio = pnversio
                                    AND ctramo = pctramo);

               -- Obtener la sumatoria de los pagos a reinstalamientos realizados (previos)
               BEGIN
                  SELECT NVL(SUM(iimport), 0)
                    INTO v_ipagos_reins_prev
                    FROM movctatecnica
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND ctramo = pctramo
                     AND fmovimi < pfcierre
                     AND NVL(nsinies, 0) = NVL(pnsinies, NVL(nsinies, 0))
                     AND NVL(cevento, 0) = NVL(pcevento, NVL(cevento, 0))
                     AND cconcep = 23;   -- Reinstalamientos XL
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_ipagos_reins_prev := 0;
               END;

               -- Obtener el valor de los pagos a reinstalamientos (para el cierre)
               BEGIN
                  SELECT NVL(SUM(iimport), 0)
                    INTO v_ipagos_reins
                    FROM movctaaux
                   WHERE scontra = pscontra
                     AND nversio = pnversio
                     AND ctramo = pctramo
                     AND fmovimi = pfcierre
                     AND NVL(nsinies, 0) = NVL(pnsinies, NVL(nsinies, 0))
                     AND NVL(cevento, 0) = NVL(pcevento, NVL(cevento, 0))
                     AND cconcep = 23;   -- Reinstalamientos XL
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     v_ipagos_reins := 0;
               END;

               -- Evaluar capacidad de pagos de reinstalamientos
               IF ((v_icap_repos -(v_ipagos_reins_prev + v_ipagos_reins)) < piimport) THEN
                  p_tab_error
                     (f_sysdate, f_user, v_object, v_traza,
                      'Error validando capacidad de Pagos de Reinstalamientos',
                      'La capacidad del Contrato/Tramo/Reinstalamientos es menor a los pagos realizados');
                  RETURN 9906337;
               END IF;   -- si concepto 23
            END IF;
         END IF;
      ELSE   -- No es concepto ni 5, ni 23
         RETURN 0;   -- No valida capacidad
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_valida_capacidad_contrato', 2,
                     'v_traza : ' || v_traza, SQLERRM);
         RETURN 9906338;
   END f_valida_capacidad_contrato;

   FUNCTION f_insertar_movprevio(
      psproces IN NUMBER,
      pscontra IN NUMBER,
      pcempres IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      ptdescrip IN VARCHAR2,
      pnidentif IN VARCHAR2,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcevento IN VARCHAR2,
      pcgarant IN NUMBER,
      pnidout IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_REA.f_insertar_movprevio';
      v_param        VARCHAR2(800)
         := 'params : psproces : ' || psproces || ' - pscontra:' || pscontra || ' - pcempres:'
            || pcempres || ' - pnversio:' || pnversio || ' - pctramo:' || pctramo
            || ' - pfcierre:' || pfcierre || ' - ptdescrip:' || ptdescrip || ' - pnidentif:'
            || pnidentif || ' - pcconcep:' || pcconcep || ' - pcdebhab:' || pcdebhab
            || ' - piimport:' || piimport || ' - pnsinies:' || pnsinies || ' - pnpoliza:'
            || pnpoliza || ' - pncertif:' || pncertif || ' - pcevento:' || pcevento
            || ' - pcgarant:' || pcgarant || ' - pnidout:' || pnidout;
      v_pasexec      NUMBER(5) := 0;
      v_importe      NUMBER;
      v_sproduc      seguros.sproduc%TYPE := 0;
      v_ccompani     seguros.ccompani%TYPE;
      v_fsinies      sin_siniestro.fsinies%TYPE;
      v_pnsinies     sin_siniestro.nsinies%TYPE := 0;
      v_sseguro      seguros.sseguro%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_scontra      NUMBER;
      v_nversio      NUMBER;
      v_ipleno       NUMBER;
      v_icapaci      NUMBER;
      v_cdetces      NUMBER;
      v_cdevento     NUMBER;
      vnumerr        NUMBER := 0;
      v_iprovis      NUMBER := 0;
      v_total_imp_sin NUMBER := 0;
      v_import_sin   NUMBER := 0;
   BEGIN
      v_pasexec := 1;

      IF pcevento IS NULL THEN   ---EVENTO
         IF pnpoliza IS NOT NULL
            OR pnsinies IS NOT NULL THEN
            v_pasexec := 2;

            IF pnpoliza IS NOT NULL THEN
               BEGIN
                  SELECT sproduc, ccompani, sseguro
                    INTO v_sproduc, v_ccompani, v_sseguro
                    FROM seguros
                   WHERE npoliza = pnpoliza
                     AND ncertif = NVL(pncertif, 0)
                     AND cempres = pcempres;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
                     RETURN 103946;
               END;
            END IF;

            v_pasexec := 3;

            IF pnsinies IS NOT NULL THEN
               v_pasexec := 4;

               IF NVL(pac_parametros.f_parempresa_n(pcempres, 'CTACES_DET'), 0) = 1 THEN
                  v_pnsinies := pnsinies;
               ELSE
                  v_pnsinies := 0;
               END IF;

               v_pasexec := 5;

               BEGIN
                  SELECT SIN.ccompani, SIN.sseguro, SIN.fsinies
                    INTO v_ccompani, v_sseguro, v_fsinies
                    FROM sin_siniestro SIN
                   WHERE SIN.nsinies = pnsinies;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);   --AXIS_LITERALES
                     RETURN 9001940;
               END;
            END IF;

            v_pasexec := 6;

            SELECT cramo, cmodali, ctipseg, ccolect, cactivi
              INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi
              FROM seguros
             WHERE sseguro = v_sseguro;

            v_pasexec := 7;

            IF v_fsinies IS NULL THEN
               v_fsinies := pfcierre;
            END IF;

            -- BUG 28492 - INICIO - DCT - 11/10/2013 - A?dir pilimsub
            v_pasexec := 8;
            vnumerr := f_buscacontrato(v_sseguro, v_fsinies, pcempres, pcgarant, v_cramo,
                                       v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 11,
                                       v_scontra, v_nversio, v_ipleno, v_icapaci, v_cdetces,
                                       NVL(pcevento, 0));

            -- BUG 28492 - FIN - DCT - 11/10/2013 - A?dir pilimsub
            IF vnumerr <> 0 THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                           vnumerr || '-' || v_param || '-----' || v_sseguro || '-'
                           || v_fsinies || '-' || pcempres || '-' || pcgarant || '-'
                           || v_cramo || '-' || v_cmodali || '-' || v_ctipseg || '-'
                           || v_ccolect || '-' || v_cactivi || '-' || v_scontra || '-'
                           || v_nversio || '-' || v_ipleno || '-' || v_icapaci || '-'
                           || v_cdetces || '-' || pcevento,
                           SQLERRM);
               RETURN vnumerr;   --140999;--axis_literales
            END IF;

            v_pasexec := 9;

            -- INI - 4818 - ML - LOS CONTRATOS YA ESTAN ASOCIADOS, EL CONTRATO QUE SE BUSCA, NO SE UTILZA PARA EL CALCULO Y REGISTRO DE APUNTES, ASI QUE NO ES NECESARIA ESTA VALIDACION
			--            IF v_scontra <> pscontra
			--               OR v_nversio <> pnversio THEN
			--               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
			--               RETURN 9000625;   --axis_literales
			--            END IF;
			-- FIN - 4818 - ML - LOS CONTRATOS YA ESTAN ASOCIADOS, EL CONTRATO QUE SE BUSCA, NO SE UTILZA PARA EL CALCULO Y REGISTRO DE APUNTES, ASI QUE NO ES NECESARIA ESTA VALIDACION

         END IF;   -- Y que pasa si poliza y siniestro es nulo

         -- Inicio BUG - RCM - 03/11/2013 - Valida capacidad del contrato
         v_pasexec := 18;
         vnumerr := pac_rea.f_valida_capacidad_contrato(pcempres, pscontra, pnversio, pctramo,
                                                        pfcierre, ptdescrip, pnidentif,
                                                        pcconcep, pcdebhab, piimport, pnsinies,
                                                        pnpoliza, pncertif, pcevento, pcgarant,
                                                        pnidout);

         IF vnumerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
            RETURN vnumerr;   --axis_literales
         END IF;

         -- Fin BUG - RCM - 03/11/2013 - Valida capacidad del contrato
         v_pasexec := 10;

         BEGIN
            INSERT INTO mov_manual_prev
                        (cempres, scontra, nversio, ctramo, fcierre, tdescrip,
                         nidentif, cconcep, cdebhab, iimport, nsinies, npoliza,
                         ncertif, cevento, cgarant, nid, falta, cusualt, fmodifi,
                         cusumod)
                 VALUES (pcempres, pscontra, pnversio, pctramo, pfcierre, ptdescrip,
                         pnidentif, pcconcep, pcdebhab, piimport, pnsinies, pnpoliza,
                         pncertif, pcevento, pcgarant, pnidout, f_sysdate, f_user, f_sysdate,
                         f_user);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               vnumerr := 108468;
         END;

         IF vnumerr <> 0 THEN
            ROLLBACK;
            RETURN vnumerr;
         END IF;

         v_pasexec := 11;
         vnumerr := f_insertar_movctaaux(pcempres, pnidout, psproces, pnsinies, piimport,
                                         v_sproduc);
      ELSE
         -- Inicio BUG - RCM - 03/11/2013 - Valida capacidad del contrato
         v_pasexec := 19;
         vnumerr := pac_rea.f_valida_capacidad_contrato(pcempres, pscontra, pnversio, pctramo,
                                                        pfcierre, ptdescrip, pnidentif,
                                                        pcconcep, pcdebhab, piimport,
                                                        pnsinies, pnpoliza, pncertif,
                                                        pcevento, pcgarant, pnidout);

         IF vnumerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
            RETURN vnumerr;   --axis_literales
         END IF;

         -- Fin BUG - RCM - 03/11/2013 - Valida capacidad del contrato
         v_pasexec := 12;

         BEGIN
            INSERT INTO mov_manual_prev
                        (cempres, scontra, nversio, ctramo, fcierre, tdescrip,
                         nidentif, cconcep, cdebhab, iimport, nsinies, npoliza,
                         ncertif, cevento, cgarant, nid, falta, cusualt, fmodifi,
                         cusumod)
                 VALUES (pcempres, pscontra, pnversio, pctramo, pfcierre, ptdescrip,
                         pnidentif, pcconcep, pcdebhab, piimport, pnsinies, pnpoliza,
                         pncertif, pcevento, pcgarant, pnidout, f_sysdate, f_user, f_sysdate,
                         f_user);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
               vnumerr := 108468;   --Error al insertar en la tabla
         END;

         IF vnumerr <> 0 THEN
            ROLLBACK;
            RETURN vnumerr;
         END IF;

         v_pasexec := 13;

         FOR reg IN (SELECT nsinies
                       FROM sin_siniestro
                      WHERE cevento = pcevento) LOOP
            --para todos los sin del evento sum ivalora= valor_a
            vnumerr := pac_siniestros.f_get_provision(reg.nsinies, NULL, 99, v_iprovis);
            v_total_imp_sin := v_iprovis + v_total_imp_sin;
         END LOOP;

         v_pasexec := 14;

         FOR reg IN (SELECT nsinies
                       FROM sin_siniestro
                      WHERE cevento = pcevento) LOOP
            vnumerr := pac_siniestros.f_get_provision(reg.nsinies, NULL, 99, v_iprovis);
            v_pasexec := 15;
            v_import_sin := piimport * v_iprovis / v_total_imp_sin;
            vnumerr := f_insertar_movctaaux(pcempres, pnidout, psproces, reg.nsinies,
                                            v_import_sin, NULL);

            IF vnumerr <> 0 THEN
               RETURN vnumerr;
            END IF;

            v_pasexec := 16;
         END LOOP;
      END IF;   -- Se termina la evaluacion por evento

      v_pasexec := 17;

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RETURN vnumerr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 105802;   --Error al insetar en movctaaux
   END f_insertar_movprevio;

   FUNCTION f_insertar_movctaaux(
      pcempres IN NUMBER,
      pnid IN NUMBER,
      psproces IN NUMBER,
      pnsinies IN NUMBER,
      piimport IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_REA.f_insertar_movctaaux';
      v_param        VARCHAR2(500)
         := 'params : pcempres : ' || pcempres || ' - pnid:' || pnid || ' - pnsinies:'
            || pnsinies || ' - psproces:' || psproces || ' - piimport:' || piimport
            || ' -psproduc:' || psproduc;
      v_pasexec      NUMBER(5) := 0;
      v_importe      NUMBER;
      vnumerr        NUMBER := 0;
      w_nnumlin      NUMBER;
      v_psproces     NUMBER;
   BEGIN
      FOR regis IN (SELECT scontra, nversio, ctramo, fcierre, tdescrip, nidentif, cconcep,
                           cdebhab, iimport, nsinies, npoliza, ncertif, cevento, cgarant
                      FROM mov_manual_prev
                     WHERE nid = pnid
                       AND cempres = pcempres) LOOP
         FOR reg IN (SELECT ccompani, pcesion
                       FROM cuadroces
                      WHERE nversio = regis.nversio
                        AND scontra = regis.scontra
                        AND ctramo = regis.ctramo) LOOP
            v_pasexec := 1;

            SELECT NVL(MAX(nnumlin), 0) + 1
              INTO w_nnumlin
              FROM movctaaux
             WHERE scontra = regis.scontra
               AND nversio = regis.nversio
               AND ctramo = regis.ctramo
               AND ccompani = reg.ccompani;

            v_importe := piimport * reg.pcesion / 100;
            v_pasexec := 2;
            vnumerr := f_procesini(f_user, pcempres, 'CIERRE_PB', 'sproces apuntes manuales',
                                   v_psproces);

            IF vnumerr <> 0 THEN
               vnumerr := 109388;
            END IF;

            BEGIN
               INSERT INTO movctaaux
                           (ccompani, nversio, scontra, ctramo,
                            nnumlin, fmovimi, fefecto, cconcep,
                            cdebhab, iimport, cestado, sproces, scesrea, cempres,
                            fcierre, sproduc, npoliza, ncertif, nsinies,
                            ccompapr, cevento, nid)
                    VALUES (reg.ccompani, regis.nversio, regis.scontra, regis.ctramo,
                            w_nnumlin, regis.fcierre, regis.fcierre, regis.cconcep,
                            regis.cdebhab, v_importe, 1, v_psproces, NULL, pcempres,
                            regis.fcierre, psproduc, regis.npoliza, regis.ncertif, pnsinies,
                            reg.ccompani, regis.cevento, pnid);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
                  vnumerr := 105802;
            END;

            v_pasexec := 3;
         END LOOP;
      END LOOP;

      IF vnumerr <> 0 THEN
         ROLLBACK;
         RETURN vnumerr;
      ELSE
         COMMIT;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 105802;   --Error algrabar en movctaaux
   END f_insertar_movctaaux;

   FUNCTION f_graba_real_movmanual_rea(pcempres IN NUMBER, pnid IN NUMBER)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_REA.f_graba_real_movmanual_rea';
      v_param        VARCHAR2(500) := 'params : pcempres : ' || pcempres || ' - pnid:' || pnid;
      v_pasexec      NUMBER(5) := 0;
      vnumerr        NUMBER := 0;
      v_cmoncontab   parempresas.nvalpar%TYPE
                                    := pac_parametros.f_parempresa_n(pcempres, 'MONEDACONTAB');
      v_cmultimon    parempresas.nvalpar%TYPE
                             := NVL(pac_parametros.f_parempresa_n(pcempres, 'MULTIMONEDA'), 0);
      v_fcambio      DATE;
      v_pago         NUMBER;
      v_reserva      NUMBER;
      v_itasa        NUMBER;
      v_signo        NUMBER := 1;
      v_cdebhab      NUMBER;
      v_tmp_iresrea  NUMBER;
      v_tmp_iresrea_moncon NUMBER;
   BEGIN
      v_tmp_iresrea := 0;
      v_tmp_iresrea_moncon := 0;

      FOR reg IN (SELECT ccompani, nversio, scontra, ctramo, nnumlin, fmovimi, fefecto,
                         cconcep, cdebhab, iimport, cestado, sproces, scesrea, cempres,
                         fcierre, sproduc, npoliza, ncertif, nsinies, ccompapr, cevento, nid
                    FROM movctaaux
                   WHERE nid = pnid
                     AND pcempres = pcempres) LOOP
         IF reg.cconcep = 5 THEN
            v_pago := reg.iimport;
            v_reserva := 0;
         ELSE
            v_reserva := reg.iimport;
            v_pago := 0;
         END IF;

         -- BUG25597:DRA:Inici: Decidimos el signo de los importes en funci? del Debe/Haber del concepto
         BEGIN
            SELECT cdebhab
              INTO v_cdebhab
              FROM tipoctarea
             WHERE cempres = pcempres
               AND cconcep = reg.cconcep;

            IF v_cdebhab <> NVL(reg.cdebhab, v_cdebhab) THEN
               v_signo := -1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_signo := 1;
         END;

         -- BUG25597:DRA:Fi
         vnumerr := pac_oper_monedas.f_datos_contraval(NULL, NULL, reg.scontra, reg.fcierre, 3,
                                                       v_itasa, v_fcambio);

         IF reg.cconcep IN(25, 5)
            AND vnumerr = 0 THEN
            BEGIN
               INSERT INTO liquidareaxl_aux
                           (nsinies, fsinies, itotexp, itotind,
                            fcierre, sproces, scontra, nversio, ctramo,
                            ccompani, pcuorea, icuorea, ipagrea,
                            iliqrea, ireserv, iresind, pcuotot, itotrea,
                            iresrea, ilimind, iliqnet,
                            iresnet, iresgas, iresindem, iresinter,
                            iresadmin, icuorea_moncon,
                            ilimind_moncon,
                            iliqnet_moncon,
                            iliqrea_moncon,
                            ipagrea_moncon, ireserv_moncon, iresgas_moncon,
                            iresindem_moncon,
                            iresinter_moncon,
                            iresadmin_moncon,
                            iresind_moncon,
                            iresnet_moncon,
                            iresrea_moncon,
                            itotexp_moncon,
                            itotind_moncon,
                            itotrea_moncon,
                            nid, cevento)
                    VALUES (   -- nsinies, fsinies, itotexp, itotind,
                            reg.nsinies, reg.fcierre, v_signo * v_pago, v_signo * v_pago,
                            -- fcierre, sproces, scontra, nversio, ctramo,
                            reg.fcierre, reg.sproces, reg.scontra, reg.nversio, reg.ctramo,
                            -- ccompani, pcuorea, icuorea, ipagrea,
                            reg.ccompani, 100, v_signo * v_pago, v_signo * v_pago,
                            --  iliqrea, ireserv, iresind, pcuotot, itotrea,
                            v_signo * v_pago, 0, 0, 100, v_signo * v_pago,
                            -- iresrea, ilimind, iliqnet,
                            v_signo * v_reserva, v_signo * 0, v_signo * v_pago,
                            -- iresnet, iresgas, iresindem, iresinter,
                            v_signo * v_reserva, v_signo * 0, v_signo * 0, v_signo * 0,
                            -- iresadmin, icuorea_moncon,
                            v_signo * 0, v_signo * f_round(v_pago * v_itasa, v_cmoncontab),
                            -- ilimind_moncon,
                            v_signo * f_round(NVL(0, 0) * v_itasa, v_cmoncontab),   --etm aqui
                            -- iliqnet_moncon,
                            v_signo * f_round(NVL(v_pago, 0) * v_itasa, v_cmoncontab),
                            -- iliqrea_moncon
                            v_signo * f_round(NVL(v_pago, 0) * v_itasa, v_cmoncontab),
                            -- ipagrea_moncon, ireserv_moncon, iresgas_moncon,
                            v_signo * f_round(NVL(v_pago, 0) * v_itasa, v_cmoncontab), 0, 0,
                            -- iresindem_moncon,
                            v_signo * f_round(0 * v_itasa, v_cmoncontab),
                            -- iresinter_moncon,
                            v_signo * f_round(0 * v_itasa, v_cmoncontab),
                            -- iresadmin_moncon,
                            v_signo * f_round(0 * v_itasa, v_cmoncontab),
                            -- iresind_moncon,
                            v_signo * f_round(0 * v_itasa, v_cmoncontab),
                            -- iresnet_moncon,
                            v_signo * f_round(NVL(v_reserva, 0) * v_itasa, v_cmoncontab),
                            -- iresrea_moncon,
                            v_signo * f_round(NVL(v_reserva, 0) * v_itasa, v_cmoncontab),
                            -- itotexp_moncon,
                            v_signo * f_round(NVL(v_pago, 0) * v_itasa, v_cmoncontab),
                            -- itotind_moncon,
                            v_signo * f_round(NVL(v_pago, 0) * v_itasa, v_cmoncontab),
                            -- itotrea_moncon
                            v_signo * f_round(NVL(v_pago, 0) * v_itasa, v_cmoncontab),
                            reg.nid, reg.cevento);

               v_tmp_iresrea := v_tmp_iresrea + v_signo * v_reserva;
               v_tmp_iresrea_moncon := v_tmp_iresrea_moncon
                                       + v_signo
                                         * f_round(NVL(v_reserva, 0) * v_itasa, v_cmoncontab);
            EXCEPTION
               WHEN OTHERS THEN
                  v_pasexec := 10;
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                              'Err INSERT INTO liquidareaxl_aux ,v_param =' || v_param,
                              'SQLERRM = ' || SQLERRM);
                  vnumerr := 9905819;   --Error al insertar en la tabla LIQUIDAREAXL_AUX
            END;
         END IF;

         IF reg.cconcep = 5
            AND vnumerr = 0 THEN
            BEGIN
               INSERT INTO pagosreaxl_aux
                           (nsinies, scontra, nversio, ctramo, ccompani,
                            fcierre, sproces, iliqrea, cestliq,
                            iliqrea_moncon,
                            fcambio,
                            nid, cevento)
                    VALUES (reg.nsinies, reg.scontra, reg.nversio, reg.ctramo, reg.ccompani,
                            reg.fcierre, reg.sproces, v_signo * v_pago, 0,
                            v_signo * f_round(v_pago * v_itasa, v_cmoncontab),
                            DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, reg.fcierre)),
                            reg.nid, reg.cevento);
            EXCEPTION
               WHEN OTHERS THEN
                  v_pasexec := 14;
                  p_tab_error(f_sysdate, f_user, v_object, v_pasexec,
                              'Err INSERT INTO pagosreaxl', ' SQLERRM = ' || SQLERRM);
                  vnumerr := 9905820;   --Error al insertar en la tabla PAGOSREAXL_AUX
            END;
         END IF;
      END LOOP;

      IF vnumerr = 0 THEN
         UPDATE liquidareaxl_aux
            SET iresrea = v_tmp_iresrea,
                iresrea_moncon = v_tmp_iresrea_moncon
          WHERE nid = pnid;
      END IF;

      IF vnumerr <> 0 THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, 'Err vnumerr' || vnumerr,
                     ' SQLERRM = ' || SQLERRM);
         RETURN vnumerr;
      ELSE
         UPDATE mov_manual_prev
            SET ntraspasado = 1
          WHERE nid = pnid
            AND pcempres = pcempres;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param, SQLERRM);
         RETURN 108468;
   END f_graba_real_movmanual_rea;

-- FIN Bug 26444 - ETM - 31/07/2012 - se crea la funcion

   /*************************************************************************
    Funci? que devuelve  la p?iza y el certificado al que pertenece un siniestro
    *************************************************************************/
    -- Bug 23830 - DCT- 04/09/2013 -
   FUNCTION f_get_npoliza(pnsinies IN NUMBER, pnpoliza OUT NUMBER, pncertif OUT NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      SELECT s.npoliza, s.ncertif
        INTO pnpoliza, pncertif
        FROM seguros s, sin_siniestro si
       WHERE s.sseguro = si.sseguro
         AND si.nsinies = pnsinies;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_get_npoliza', 1, 'pnsinies = ' || pnsinies,
                     SQLERRM);
         RETURN 103212;   --Error al ejecutar la consulta
   END f_get_npoliza;

   FUNCTION f_del_contrato_rea(pscontra IN NUMBER)   --ob
      RETURN NUMBER IS
      num_err        NUMBER := 0;
   BEGIN
      DELETE FROM reposiciones_det
            WHERE ccodigo IN(SELECT crepos
                               FROM tramos
                              WHERE scontra = pscontra);

      DELETE FROM reposiciones
            WHERE ccodigo IN(SELECT crepos
                               FROM tramos
                              WHERE scontra = pscontra);

      DELETE FROM cod_reposicion
            WHERE ccodigo IN(SELECT crepos
                               FROM tramos
                              WHERE scontra = pscontra);

      DELETE FROM tramos
            WHERE scontra = pscontra;

      DELETE FROM reaformula
            WHERE scontra = pscontra;

      DELETE FROM reariesgos
            WHERE scontra = pscontra;

      DELETE FROM codicontratosagr
            WHERE sconagr IN(SELECT sconagr
                               FROM codicontratos
                              WHERE scontra = pscontra);

      DELETE FROM agr_contratos
            WHERE scontra = pscontra;

      DELETE FROM cuadroces
            WHERE scontra = pscontra;

      DELETE FROM contratos
            WHERE scontra = pscontra;

      DELETE FROM codicontratos
            WHERE scontra = pscontra;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_rea.f_del_cuadroces', 2,
                     'pscontra : ' || pscontra, SQLERRM);
         RETURN 103870;
   END f_del_contrato_rea;

   FUNCTION f_set_liquida(
      pspagrea IN NUMBER,
      pfcambio IN DATE,
      pcestpag IN NUMBER,
      piimporte IN pagos_ctatec_rea.iimporte%TYPE,
      piimporte_moncon IN pagos_ctatec_rea.iimporte_moncon%TYPE,
      pctipopag IN pagos_ctatec_rea.ctipopag%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_object       VARCHAR2(500) := 'PAC_REA.f_set_liquida';
      vparam         VARCHAR2(800) := 'parametros - pspagrea :' || pspagrea;
      v_pasexec      NUMBER(5) := 0;
   BEGIN
      IF (NVL(piimporte, 0) <> 0) THEN
         v_pasexec := 10;

         UPDATE pagos_ctatec_rea
            SET cestado = 0,
                fliquida = f_sysdate,
                iimporte_moncon = piimporte_moncon,
                fcambio = pfcambio,
                ctipopag = pctipopag,
                iimporte = piimporte
          WHERE spagrea = pspagrea;

         UPDATE movctatecnica
            SET cestado = 0
          WHERE spagrea = pspagrea;
      END IF;

      v_pasexec := 20;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, vparam, SQLERRM);
         RETURN 140999;
   --Error no controlado
   END f_set_liquida;

FUNCTION f_edit_compani_doc(
          pccompani IN NUMBER,
          piddocgdx IN NUMBER,
          pctipo    IN NUMBER,
          ptobserv  IN VARCHAR2,
          pfcaduci  IN DATE,
          pfalta    IN DATE,
          mensajes  IN OUT t_iax_mensajes)
     RETURN NUMBER
IS
     --
     e_object_error EXCEPTION;
     e_param_error  EXCEPTION;
     vpasexec       NUMBER := 1;
     vobject        VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_edit_compani_doc';
     vparam         VARCHAR2(500) := 'pccompani: ' || pccompani || ' piddocgdx: ' || piddocgdx ||
     ' pctipo: ' || pctipo || ' ptobserv: ' || ptobserv || ' pfcaduci: ' || pfcaduci || ' pfalta: '
     || pfalta;
     --
BEGIN
     --
     UPDATE cmpani_doc
     SET  ctipo = pctipo, tobserv = ptobserv, fcaduci = pfcaduci
     WHERE ccompani = pccompani
      AND iddocgdx = piddocgdx;
     --
     RETURN 0;
     --
EXCEPTION
WHEN e_param_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
     RETURN 1;
WHEN e_object_error THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
     RETURN 1;
WHEN OTHERS THEN
     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
     SQLCODE, psqerrm => SQLERRM);
     RETURN 1;
END f_edit_compani_doc;

  FUNCTION f_ins_compani_doc(
            pccompani IN NUMBER,
            piddocgdx IN NUMBER,
            pctipo    IN NUMBER,
            ptobserv  IN VARCHAR2,
            pfcaduci  IN DATE,
            pfalta    IN DATE,
            mensajes  IN OUT t_iax_mensajes)
       RETURN NUMBER
  IS
       --
       e_object_error EXCEPTION;
       e_param_error  EXCEPTION;
       vpasexec       NUMBER := 1;
       vobject        VARCHAR2(200) := 'PAC_CONTRAGARANTIAS.f_ins_compani_doc';
       vparam         VARCHAR2(500) := 'pccompani: ' || pccompani || ' piddocgdx: ' || piddocgdx ||
       ' pctipo: ' || pctipo || ' ptobserv: ' || ptobserv || ' pfcaduci: ' || pfcaduci || ' pfalta: '
       || pfalta;
       --
  BEGIN
       --
       INSERT
       INTO cmpani_doc
            (
                 ccompani, iddocgdx, ctipo, tobserv, fcaduci, falta
            )
            VALUES
            (
                 pccompani, piddocgdx, pctipo, ptobserv, pfcaduci,NVL(pfalta, f_sysdate)
            );
       --
       COMMIT;
       RETURN 0;
       --
  EXCEPTION
  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
       RETURN 1;
  WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
       RETURN 1;
  WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam, psqcode =>
       SQLCODE, psqerrm => SQLERRM);
       RETURN 1;
  END f_ins_compani_doc;

FUNCTION f_get_reaseguro_x_garantia(
      ptabla IN VARCHAR2,
      ppoliza IN NUMBER,
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pcgenera IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_rea.f_get_reaseguro_x_garantia_reporte';
      vparam         VARCHAR2(500) := '';
      v_monprod monedas.cmonint%TYPE;--moneda del producto
      v_moninst monedas.cmonint%TYPE;--moneda local
      v_sproduc productos.sproduc%TYPE;
	   rec        NUMBER := 0;  
        psproces2  VARCHAR2(500) := '';
        pcgenera2 VARCHAR2(500) := '';
        Countsp    NUMBER := 0;  
        fconini1  DATE := '';
        fconfin2  DATE := '';
        nversio2 VARCHAR2(500) := '';


   BEGIN

   --Se crean las consultas de la linea 4801 a 4835 para acumular valores de en las variables, IAXIS-4615
   --1.rec --> bandera para saber si el seguro consultado tiene RECOBRO.
   --2.psproces2 --> varieble para saber la variable  proceso del recobro.
   --3.fconini1 --->  fconini1 guarda la fecha de inicio del contrato para RECOBRO.
   --4.fconfin2 --->  fconfin2 guarda la fecha fin del contrato para RECORBO.
   --5.nversio2 --->  nversio2 guarda la verion para el RECOBRO
   --6 Se modifico los cursores de TABLA X Y TABLA B RECOBRO.



                         SELECT COUNT(*) 
                                INTO Countsp
                                FROM SIN_TRAMITA_PAGO SP
                                INNER JOIN SIN_TRAMITA_PAGO STP ON STP.SIDEPAG=SP.SIDEPAG
                                INNER JOIN SIN_TRAMITA_MOVPAGO STM ON STM.SIDEPAG=STP.SIDEPAG
                                INNER JOIN CESIONESREA CR ON CR.NSINIES=STP.NSINIES
                                INNER JOIN SEGUROS SG ON SG.SSEGURO=CR.SSEGURO
                                --INNER JOIN DETVALORES DV ON DV.CATRIBU = CR.CGENERA
                                INNER JOIN CONTRATOS CO ON  CO.SCONTRA = CR.SCONTRA
                         WHERE SG.SSEGURO=psseguro AND SP.CTIPPAG='7';


                             SELECT nversio,sproces,cgenera,fconini,fconfin 
                                    INTO nversio2,psproces2,pcgenera2,fconini1,fconfin2
                                    FROM ( SELECT  ct.nversio,sproces,cgenera,CT.fconini,CT.fconfin
                                 FROM CESIONESREA CL
                                 -- INICIO INFORCOL 14-05-2020 Recobros: Ajuste en consulta contratos del movimiento
                                 INNER JOIN CONTRATOS CT ON CT.SCONTRA=CL.SCONTRA AND CT.NVERSIO = CL.NVERSIO
                                 -- FIN INFORCOL 14-05-2020 Recobros: Ajuste en consulta contratos del movimiento
                                WHERE CL.SSEGURO =psseguro
                                  --  AND c1.sproces =psproces
                                  --AND c1.cgenera = pcgenera
                                   order by ct.nversio DESC) where rownum=1;



                            select 
                                          SUM(ISINRET)
                                          INTO rec                                                                
                            FROM SIN_TRAMITA_PAGO WHERE SIDEPAG IN (
                                SELECT SP.SIDEPAG  FROM SIN_TRAMITA_PAGO SP
                                INNER JOIN SIN_TRAMITA_PAGO STP ON STP.SIDEPAG=SP.SIDEPAG
                                INNER JOIN SIN_TRAMITA_MOVPAGO STM ON STM.SIDEPAG=STP.SIDEPAG
                                INNER JOIN CESIONESREA CR ON CR.NSINIES=STP.NSINIES
                                INNER JOIN SEGUROS SG ON SG.SSEGURO=CR.SSEGURO
                                INNER JOIN CONTRATOS CO ON  CO.SCONTRA = CR.SCONTRA
                                WHERE SG.SSEGURO=psseguro AND SP.CTIPPAG='7' GROUP BY SP.SIDEPAG);   



      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT cmonint
        INTO v_monprod
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_monedas.f_moneda_producto(v_sproduc);

      SELECT cmonint
        INTO v_moninst
        FROM monedas
       WHERE cidioma = pac_md_common.f_get_cxtidioma
         AND cmoneda = pac_parametros.f_parinstalacion_n ('MONEDAINST');	

p_tab_error(f_sysdate, f_user, vobject, vpasexec,
                              'Traza verificacion de datos,ptabla =' || ptabla || '-'||Countsp|| '-VMONIST'||v_moninst||'-VMONPROD'||v_monprod||'-PSPROCES'|| psproces ||'-PCGENERA'||pcgenera||'-PSSEGURO'||psseguro,
                              'FEPP = ');
      IF ppoliza IS NOT NULL
         AND psseguro IS NOT NULL THEN
         IF ptabla = 'X' and Countsp>0 THEN
            OPEN v_cursor FOR
                                        select 
                                                cgenera,
                                                nversio,
                                                sproces, 
                                                policy_no,
                                                motivo,
                                                ano_con,
                                                fec_ini,
                                                fec_fin,
                                                porcesion,
                                                impvalase,
                                                impcesion 
                                                from (
                                              SELECT   cr.cgenera,cr.nversio, cr.sproces, s.npoliza policy_no, dv.tatribu motivo,
                                                                TO_CHAR(co.fconini, 'YYYY') ano_con,
                                                    TO_CHAR(co.fconini, 'DD/MM/YYYY') fec_ini,
                                                    TO_CHAR(co.fconfin, 'DD/MM/YYYY') fec_fin,
                                                    TO_CHAR(SUM(cr.pcesion), '99,999,999,999,999,999,999.99') porcesion,                                                 
                                                    
                                                      CASE WHEN cr.cgenera=4 then 
                                                     
                                                          TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                       cr.fgenera,
                                                                        NVL(cr.icapces, 0))),0), '99,999,999,999,999,999,999.99')
                                                          
                                                           WHEN cr.cgenera=2 then
                                                           
                                                           TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                         st.fordpag,
                                                                        NVL(cr.icapces, 0))),0), '99,999,999,999,999,999,999.99')
                                                                        
                                                            else                                                        
                                                           
                                                                        
                                                            TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                                v_moninst,
                                                                               cr.fefecto,
                                                                                NVL(cr.icapces, 0))),0), '99,999,999,999,999,999,999.99')
                                                                                
                                                                        end impvalase,
                                                                        
                                                       CASE WHEN cr.cgenera=4 then 
                                                                 
                                                              TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                    v_moninst,
                                                                     cr.fgenera,
                                                                    NVL(cr.icesion, 0))),0)
                                                                    , '99,999,999,999,999,999,999.99')
                                                                    
                                                            WHEN cr.cgenera=2 then 
                                                            
                                                            TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                    v_moninst,
                                                                     st.fordpag,
                                                                    NVL(cr.icesion, 0))),0)
                                                                    , '99,999,999,999,999,999,999.99')
                                                                    
                                                                    else
                                                            
                                                             TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                         cr.fefecto,
                                                                        NVL(cr.icesion, 0))),0)
                                                                        , '99,999,999,999,999,999,999.99') end impcesion
                                                  
                                                                                                                             
                                                    /*TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                       cr.fefecto,
                                                                        NVL(cr.icapces, 0))),0), '99,999,999,999,999,999,999.99') impvalase,
                                                    TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                         cr.fefecto,
                                                                        NVL(cr.icesion, 0))),0)
                                                                        , '99,999,999,999,999,999,999.99') impcesion*/
                                          --INI IAXIS-BUG-12907 AABG - 21-02-2020: Se hace Join con nueva tabla para obtener unicamente valores validos para sumatoria 
                                               FROM seguros s, contratos co, detvalores dv, cesionesrea cr
                                                FULL OUTER JOIN sin_tramita_pago st
                                                ON cr.sidepag = st.sidepag
                                          --FIN IAXIS-BUG-12907 AABG - 21-02-2020: Se hace Join con nueva tabla para obtener unicamente valores validos para sumatoria
                                              WHERE s.sseguro = psseguro
                                                AND cr.sseguro = s.sseguro
                                                AND co.scontra = cr.scontra
                                                AND co.nversio = cr.nversio
                                                AND dv.cvalor = 128
                                                AND dv.cidioma = 8
                                                AND cgenera !=7
										  --INI IAXIS-BUG-12907 AABG - 21-02-2020: Se obtiene aquellos que no sean tipo pago 7   
                                                AND NVL(st.ctippag, 0) != 7
                                          --FIN IAXIS-BUG-12907 AABG - 21-02-2020: Se obtiene aquellos que no sean tipo pago 7
                                                AND dv.catribu = cr.cgenera
                                                /*AND (cr.ctramo != 5 OR
                                                     (cr.ctramo = 5 AND cr.ctrampa = 5))*/
                                                AND (cr.ctramo != 5 OR
                                                ((cr.ctramo = 5 AND cr.ctrampa IS NULL
                                                    AND NOT EXISTS (SELECT 'X' FROM cesionesrea ces2 WHERE ces2.sseguro = cr.sseguro AND ces2.ctramo = 5 AND ces2.ctrampa = 5)
                                              ) OR
                                                     (cr.ctramo = 5 AND cr.ctrampa = 5))

                                              )

											  and (/*icesion>=0 and*/ cr.icapces>=0) --IAXIS-4811
                                           GROUP BY cr.cgenera,cr.nversio, s.npoliza, dv.tatribu, co.fconini, co.fconfin, s.sseguro,
                                                    cr.sproces

                                           UNION

                                           select 
                                        TO_NUMBER('4') cgenera,
                                        TO_NUMBER(nversio2)nversio,
                                        TO_NUMBER('0') sproces,
                                        psseguro policy_no,
                                          'Recobro' motivo,
                                                 TO_CHAR(fconini1, 'YYYY')  ano_con,
                                                TO_CHAR(fconini1, 'DD/MM/YYYY')  fec_ini,
                                                TO_CHAR(fconfin2, 'DD/MM/YYYY')  fec_fin,
                                                     TO_CHAR(NVL('100',0)
                                                                        , '99,999,999,999,999,999,999.99') porcesion,
                                                   TO_CHAR(NVL( '.00',0),'99,999,999,999,999,999,999.99') impvalase,
                                                   TO_CHAR(NVL((pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                         FORDPAG,
                                                                        NVL(ISINRET, 0))),0)
                                                                        , '99,999,999,999,999,999,999.99')
                                                     impcesion

                                                        FROM SIN_TRAMITA_PAGO WHERE SIDEPAG IN (
                                                            SELECT SP.SIDEPAG  FROM SIN_TRAMITA_PAGO SP
                                                            INNER JOIN SIN_TRAMITA_PAGO STP ON STP.SIDEPAG=SP.SIDEPAG
                                                            INNER JOIN SIN_TRAMITA_MOVPAGO STM ON STM.SIDEPAG=STP.SIDEPAG
                                                            INNER JOIN CESIONESREA CR ON CR.NSINIES=STP.NSINIES
                                                            INNER JOIN SEGUROS SG ON SG.SSEGURO=CR.SSEGURO
                                                            INNER JOIN CONTRATOS CO ON  CO.SCONTRA = CR.SCONTRA
                                                            WHERE SG.SSEGURO=psseguro AND SP.CTIPPAG='7' GROUP BY SP.SIDEPAG))  ORDER BY sproces DESC;

                            ELSE

--IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO

                                 OPEN v_cursor FOR
                                       SELECT   cr.cgenera,cr.nversio, cr.sproces, s.npoliza policy_no, dv.tatribu motivo,
                                                                TO_CHAR(co.fconini, 'YYYY') ano_con,
                                                    TO_CHAR(co.fconini, 'DD/MM/YYYY') fec_ini,
                                                    TO_CHAR(co.fconfin, 'DD/MM/YYYY') fec_fin,
                                                    TO_CHAR(SUM(cr.pcesion), '99,999,999,999,999,999,999.99') porcesion,
                                                    
                                                    CASE WHEN cr.cgenera=4 then 
                                                     
                                                          TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                       cr.fgenera,
                                                                        NVL(cr.icapces, 0))),0), '99,999,999,999,999,999,999.99')
                                                          
                                                                                                                                  
                                                            else                                                        
                                                           
                                                                        
                                                            TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                                v_moninst,
                                                                               cr.fefecto,
                                                                                NVL(cr.icapces, 0))),0), '99,999,999,999,999,999,999.99')
                                                                                
                                                                        end impvalase,
                                                                        
                                                       CASE WHEN cr.cgenera=4 then 
                                                                 
                                                              TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                    v_moninst,
                                                                     cr.fgenera,
                                                                    NVL(cr.icesion, 0))),0)
                                                                    , '99,999,999,999,999,999,999.99')
                                                                    
                                                                                                                                
                                                                    else
                                                            
                                                             TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                         cr.fefecto,
                                                                        NVL(cr.icesion, 0))),0)
                                                                        , '99,999,999,999,999,999,999.99') end impcesion
                                                    /*TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                        cr.fgenera,
                                                                        NVL(cr.icapces, 0))),0), '99,999,999,999,999,999,999.99') impvalase,
                                                    TO_CHAR(NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                        cr.fgenera,
                                                                        NVL(cr.icesion, 0))),0)
                                                                        , '99,999,999,999,999,999,999.99') impcesion*/

                                               FROM seguros s, cesionesrea cr, contratos co, detvalores dv
                                              WHERE s.sseguro = psseguro
                                                AND cr.sseguro = s.sseguro
                                                AND co.scontra = cr.scontra
                                                AND co.nversio = cr.nversio
                                                AND dv.cvalor = 128
                                                AND dv.cidioma = 8
                                                AND cgenera !=7
                                                AND dv.catribu = cr.cgenera
                                                /*AND (cr.ctramo != 5 OR
                                                     (cr.ctramo = 5 AND cr.ctrampa = 5))*/
                                                AND (cr.ctramo != 5 OR
                                                ((cr.ctramo = 5 AND cr.ctrampa IS NULL
                                                    AND NOT EXISTS (SELECT 'X' FROM cesionesrea ces2 WHERE ces2.sseguro = cr.sseguro AND ces2.ctramo = 5 AND ces2.ctrampa = 5)
                                              ) OR
                                                     (cr.ctramo = 5 AND cr.ctrampa = 5))

                                              )
                                           GROUP BY cr.cgenera,cr.nversio, s.npoliza, dv.tatribu, co.fconini, co.fconfin, s.sseguro,
                                                    cr.sproces ORDER BY sproces DESC;
                                                    
--IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO

         END IF;

		 IF ptabla = 'A' THEN
            OPEN v_cursor FOR
               SELECT cr.sproces, ppoliza poliza, c2.tcompani asegurador,
                      c1.pcesion porcentaje,
                      (NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icapces, 0)),0)  * c1.pcesion / 100) valoraseg,
                      (NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0)
                                            * c1.pcesion / 100) impcesion,
                      NVL(c1.ccomrea, c1.pcomisi) comision,

                      ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0)  * c1.pcesion / 100)
                            * NVL(c1.ccomrea, c1.pcomisi) / 100) valcomi,
                      NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(c1.preserv, 0)),0) retenido,
                      (NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0)  * c1.pcesion / 100) - NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(c1.preserv, 0)),0)
                      - ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0)  * c1.pcesion / 100)
                              * NVL(c1.ccomrea, c1.pcomisi) / 100) saldo,
                      c1.fgarpri
                 FROM cesionesrea cr, cuacesfac c1, companias c2
                WHERE cr.sseguro = psseguro
                  AND cr.sproces = psproces
                  AND cr.sfacult = c1.sfacult
                  AND c2.ccompani = c1.ccompani
                  AND cgenera !=7
                  AND ((cr.ctramo = 5 AND cr.ctrampa IS NULL
                        AND NOT EXISTS (SELECT 'X' FROM cesionesrea ces2 WHERE ces2.sseguro = cr.sseguro AND ces2.ctramo = 5 AND ces2.ctrampa = 5)
                  ) OR
                         (cr.ctramo = 5 AND cr.ctrampa = 5))
                  AND cr.nmovimi = (SELECT MAX(c3.nmovimi)
                                      FROM cesionesrea c3
                                     WHERE c3.sseguro = cr.sseguro
                                       AND c3.sproces = cr.sproces);
         END IF;


         IF ptabla = 'B' THEN
            IF psproces>0 THEN
				--INI IAXIS-BUG-12907 AABG - 21-02-2020: Se realiza ajuste para no obtener los recobros en las listas de Nueva Produccion y Pago Siniestros 
                IF pcgenera = 3 THEN

                    OPEN v_cursor FOR
                        -- INI - ML - 5028 - 05/09/2019 - LISTADO TOTAL DE REPARTITCION EN CESIONESREA
                        
--IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO

                      SELECT * FROM (
                       SELECT  c1.pcesion por_cesion, DECODE(c1.ctramo, 5, 'Fac', c1.ctramo) tramo,
                               DECODE(NVL(c1.ccutoff,'N'), 'S', (DECODE(c1.ctramo, 0, NULL, c1.ctramo)), c1.ctrampa) ctrampa,
                               TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                  v_moninst,
                                                  c1.fefecto,--BUG-13135
                                                  NVL(c1.icapces, 0)),0), '99,999,999,999,999,999,999.99') val_aseg,
                               TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                  v_moninst,
                                                  c1.fefecto,--BUG-13135
                                                  NVL(c1.icesion, 0)),0), '99,999,999,999,999,999,999.99') pri_ced
                         FROM cesionesrea c1
                        WHERE c1.sseguro = psseguro
                          AND c1.sproces = psproces
                          AND c1.cgenera = pcgenera                         
                          AND c1.cgenera !=7
                          AND (c1.ctramo != 5 OR
                            ((c1.ctramo = 5 AND c1.ctrampa IS NULL
                                AND NOT EXISTS (SELECT 'X' FROM cesionesrea ces2 WHERE ces2.sseguro = c1.sseguro AND ces2.ctramo = 5 AND ces2.ctrampa = 5)
                          ) OR
                                 (c1.ctramo = 5 AND c1.ctrampa = 5)))
                          );
                    ELSE

                    OPEN v_cursor FOR
                        -- INI - ML - 5028 - 05/09/2019 - LISTADO TOTAL DE REPARTITCION EN CESIONESREA
                      SELECT * FROM (
                       SELECT  c1.pcesion por_cesion, DECODE(c1.ctramo, 5, 'Fac', c1.ctramo) tramo,
                               DECODE(NVL(c1.ccutoff,'N'), 'S', (DECODE(c1.ctramo, 0, NULL, c1.ctramo)), c1.ctrampa) ctrampa,
                               
                               CASE WHEN c1.cgenera=4 then 
                                      TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                  v_moninst,
                                                  c1.fgenera,--BUG-13135 SE CAMBIO FGENERA POR FEFECTO
                                                  NVL(c1.icapces, 0)),0), '99,999,999,999,999,999,999.99')
                                                  
                                     WHEN c1.cgenera=2 then 
                                       TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                  v_moninst,
                                                  st.fordpag,--BUG-13135 
                                                  NVL(c1.icapces, 0)),0), '99,999,999,999,999,999,999.99')      
                                     
                                                  else
                                        TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                  v_moninst,
                                                  c1.fefecto,--BUG-13135 
                                                  NVL(c1.icapces, 0)),0), '99,999,999,999,999,999,999.99')
                                                  end                                                  
                                                  val_aseg,                                                  
                                                  
                                                  CASE WHEN c1.cgenera=4 then 
                                              TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                  v_moninst,
                                                  c1.fgenera,--BUG-13135 SE CAMBIO FGENERA POR FEFECTO
                                                       NVL(                                                       
                                                       (select 
                                                       case when (valor-(select sum(icesion) valor from cesionesrea where sseguro=psseguro and cgenera!=7 and nmovimi=c1.nmovimi))>0
                                                       then 
                                                       (valor-(select sum(icesion) valor from cesionesrea where sseguro=psseguro and cgenera!=7 and nmovimi=c1.nmovimi))*c1.PCESION/100                                                    
                                                       else
                                                       ((valor-(select sum(icesion) valor from cesionesrea where sseguro=psseguro and cgenera!=7 and nmovimi=c1.nmovimi))*-1)*c1.PCESION/100                                                    
                                                       end                                              
                                                       from (select nmovimi, sum(icesion) valor from cesionesrea where sseguro=psseguro and cgenera!=7 and nmovimi<c1.nmovimi group by nmovimi order by nmovimi desc) where rownum=1)
                                                        , 0)),0), '99,999,999,999,999,999,999.99')
                                                        
                                                          WHEN c1.cgenera=2 then 
                                                         
                                                         TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                          v_moninst,
                                                          st.fordpag,--BUG-13135 
                                                               NVL(c1.icesion, 0)),0), '99,999,999,999,999,999,999.99')                                                         
                                                        
                                                        
                                                        else TO_CHAR(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                  v_moninst,
                                                  c1.fefecto,--BUG-13135 SE CAMBIO FGENERA POR FEFECTO
                                                       NVL(c1.icesion, 0)),0), '99,999,999,999,999,999,999.99') end pri_ced
                         FROM cesionesrea c1 FULL OUTER JOIN sin_tramita_pago st
                            ON c1.sidepag = st.sidepag
                        WHERE c1.sseguro = psseguro
                          AND c1.sproces = psproces
                          AND c1.cgenera = pcgenera
                          AND NVL(st.ctippag, 0) != 7
                          AND c1.cgenera !=7
                          AND (c1.ctramo != 5 OR
                            ((c1.ctramo = 5 AND c1.ctrampa IS NULL
                                AND NOT EXISTS (SELECT 'X' FROM cesionesrea ces2 WHERE ces2.sseguro = c1.sseguro AND ces2.ctramo = 5 AND ces2.ctrampa = 5)
                          ) OR
                                 (c1.ctramo = 5 AND c1.ctrampa = 5)))
                          );
--FIN - IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO
                END IF;
				--FIN IAXIS-BUG-12907 AABG - 21-02-2020: Se realiza ajuste para no obtener los recobros en las listas de Nueva Produccion y Pago Siniestros

			-- FIN - ML - 5028 - 05/09/2019 - LISTADO TOTAL DE REPARTITCION EN CESIONESREA
               ELSE
               OPEN v_cursor FOR   
			   
			   

          SELECT   distinct (c1.pcesion) por_cesion, DECODE(c1.ctramo, 5, 'Fac', c1.ctramo) tramo,
                       DECODE(NVL(c1.ccutoff,'N'), 'S', (DECODE(c1.ctramo, 0, NULL, c1.ctramo)), c1.ctrampa) ctrampa,
                       TO_CHAR(NVL('.00',0), '99,999,999,999,999,999,999.99') val_aseg,
                       TO_CHAR(NVL((pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                                                        v_moninst,
                                                                         sp.fordpag,
                                                                        NVL(sp.isinret*(c1.pcesion)/100, 0))),0)
                                                                        , '99,999,999,999,999,999,999.99') pri_ced
                 FROM cesionesrea c1
                 inner join sin_tramita_pago sp on c1.sidepag=sp.sidepag
                WHERE c1.sseguro = psseguro 
                      AND sp.ctippag='7'; -- bug 13850
                --   c1.sproces =psproces2
                --  AND c1.cgenera = pcgenera2;                   
         END IF;
	 END IF;

--IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO
         IF ptabla = 'C' THEN
            OPEN v_cursor FOR
               SELECT   gg.tgarant garant, dc.ptramo tramo, sum (c1.pcesion) porcesi,
                        NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            c1.fefecto,
                                            NVL(dc.icapces, 0))),0) valaseg
                   FROM cesionesrea c1, det_cesionesrea dc, garangen gg, tomadores tom
                  WHERE c1.sseguro = psseguro
                    AND c1.sproces = psproces
                    AND dc.sperson = tom.sperson
                    AND dc.sseguro = tom.sseguro
                    AND dc.ptramo = c1.ctramo
                    AND dc.scesrea = c1.scesrea
                    AND gg.cgarant = dc.cgarant
                    AND gg.cidioma = 8
                    AND cgenera !=7
                    group by gg.tgarant,dc.ptramo
               ORDER BY 2;
         END IF;

         IF ptabla = 'D' THEN
            OPEN v_cursor FOR
               SELECT   gg.tgarant garant, dc.ptramo tramo, sum (c1.pcesion) porcesi,
                        NVL(SUM(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            c1.fefecto,
                                            NVL(dc.icesion, 0))),0) impces
                   FROM cesionesrea c1, det_cesionesrea dc, garangen gg, tomadores tom
                  WHERE c1.sseguro = psseguro
                    AND c1.sproces = psproces
                    AND dc.sperson = tom.sperson
                    AND dc.sseguro = tom.sseguro
                    AND dc.ptramo = c1.ctramo
                    AND dc.scesrea = c1.scesrea
                    AND gg.cgarant = dc.cgarant
                    AND gg.cidioma = 8
                    group by gg.tgarant,dc.ptramo
               ORDER BY 2;
         END IF;

         IF ptabla = 'E' THEN
            OPEN v_cursor FOR

               SELECT ppoliza poliza, c2.tcompani asegurador, c1.pcesion porcentaje,
                      TO_CHAR((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icapces, 0)),0) * c1.pcesion / 100), '99,999,999,999,999,999,999.99') valoraseg,
                      TO_CHAR((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0)   * c1.pcesion / 100), '99,999,999,999,999,999,999.99') impcesion,
                      NVL(c1.ccomrea, c1.pcomisi) comision,
                      TO_CHAR(ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
                                    * NVL(c1.ccomrea, c1.pcomisi) / 100), '99,999,999,999,999,999,999.99') valcomi,
                      --INI-IAXIS4448
                      NVL(c1.ccomrea, c1.preserv) retencion,
                      -- INICIO INFORCOL 04-02-2020 Reaseguro - Ajuste retencion local y retencion reasegurador
                      NVL(c1.presrea, 0) retencionRea,
                      -- FIN INFORCOL 04-02-2020 Reaseguro - Ajuste retencion local y retencion reasegurador
                      /*NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            f_sysdate,
                                            NVL(c1.preserv, 0)),0) */
                     -- INICIO INFORCOL 14-05-2020 Reaseguro - Reaseguro Facultativo - Deposito en prima nuevas columnas CUASEFAC - Ajuste consulta retencion local y retencion reasegurador
                      TO_CHAR(ROUND(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                        v_moninst,
                                        cr.fefecto,
                                        NVL(c1.ireserv, 0)),0)), '99,999,999,999,999,999,999.99')retenido,
                      TO_CHAR(ROUND(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                        v_moninst,
                                        cr.fefecto,
                                        NVL(c1.iresrea, 0)),0)), '99,999,999,999,999,999,999.99')retenidorea,
                      -- FIN INFORCOL 14-05-2020 Reaseguro Facultativo - Deposito en prima nuevas columnas CUASEFAC - Ajuste consulta retencion local y retencion reasegurador
                      TO_CHAR(ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
											/*INI - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                                    * NVL(c1.ccomrea, DECODE(pac_reaseguro_rec.f_compania_exenta(c1.CCOMPANI,f_sysdate),'0', 1
                                                                                                                      ,'1', 0)) / 100), '99,999,999,999,999,999,999.99') retefuente,--PENDIENTE VALIDAR PARAMETRO RETEFUENTE
									        /*FIN - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                      --FIN-IAXIS-44448
                      TO_CHAR((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100) 
                              --INI-IAXIS4448
                              /*- NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            f_sysdate,
                                            NVL(c1.preserv, 0)),0)*/
                              -  ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
									-- INICIO INFORCOL 06-02-2020 Reaseguro - Ajuste retencion local y retencion reasegurador calculo saldo	
                                    * NVL(c1.ccomrea, NVL(c1.presrea, 0)) / 100)
									-- FIN INFORCOL 06-02-2020 Reaseguro - Ajuste retencion local y retencion reasegurador calculo saldo	
                              -  ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                        cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
									/*INI - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                                    * NVL(c1.ccomrea,  DECODE(pac_reaseguro_rec.f_compania_exenta(c1.CCOMPANI,f_sysdate),'0', 1
                                                                                                                      ,'1', 0)) / 100)--PENDIENTE VALIDAR PARAMETRO RETEFUENTE
									/*FIN - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                              --FIN-IAXIS4448
                              - ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
                                      * NVL(c1.ccomrea, c1.pcomisi)
                                / 100), '99,999,999,999,999,999,999.99') saldo,
                      c1.fgarpri
                 FROM cesionesrea cr, cuacesfac c1, companias c2
                WHERE cr.sseguro = psseguro
                  AND cr.sproces = psproces
                  AND cr.sfacult = c1.sfacult
                  AND c2.ccompani = c1.ccompani
                  --AND cr.ctrampa = 5
                  AND ((cr.ctramo = 5 AND cr.ctrampa IS NULL
                        AND NOT EXISTS (SELECT 'X' FROM cesionesrea ces2 WHERE ces2.sseguro = cr.sseguro AND ces2.ctramo = 5 AND ces2.ctrampa = 5)
                  ) OR
                         (cr.ctramo = 5 AND cr.ctrampa = 5))

                  AND cr.nmovimi = (SELECT MAX(c3.nmovimi)
                                      FROM cesionesrea c3
                                     WHERE c3.sseguro = cr.sseguro
                                       AND c3.sproces = cr.sproces
                                       --ini IAXIS-4448
                                       AND c3.ctramo = 5
                                       --fin IAXIS-4448
                                      );
                                      
--FIN-IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO
         END IF;
--IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO
         IF ptabla = 'F' THEN
            OPEN v_cursor FOR
               SELECT SUM(c1.pcesion) porcentaje,
                      TO_CHAR(SUM((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icapces, 0)),0) * c1.pcesion / 100)), '99,999,999,999,999,999,999.99') valoraseg,
                      TO_CHAR(SUM((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)), '99,999,999,999,999,999,999.99') impcesion,
                      TO_CHAR(SUM(ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
                                * NVL(c1.ccomrea, c1.pcomisi) / 100)), '99,999,999,999,999,999,999.99') valcomi,
                      --INI- IAXIS-4448
                      /*SUM(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            f_sysdate,
                                            NVL(c1.preserv, 0)),0))*/
					  -- INICIO INFORCOL 14-05-2020 Reaseguro Facultativo - Deposito en prima nuevas columnas CUASEFAC - Ajuste consulta retencion local y retencion reasegurador
                      TO_CHAR(SUM(ROUND(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                        v_moninst,
                                        cr.fefecto,
                                        NVL(c1.ireserv, 0)),0))), '99,999,999,999,999,999,999.99') retenido,
                      TO_CHAR(SUM(ROUND(NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                        v_moninst,
                                        cr.fefecto,
                                        NVL(c1.iresrea, 0)),0))), '99,999,999,999,999,999,999.99') retenidorea,
                      -- FIN INFORCOL 14-05-2020 Reaseguro Facultativo - Deposito en prima nuevas columnas CUASEFAC - Ajuste consulta retencion local y retencion reasegurador
                                -- FIN INFORCOL 04-02-2020 Reaseguro - Ajuste retencion local y retencion reasegurador
                      TO_CHAR(SUM(ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
											/*INI - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                                * NVL(c1.ccomrea,  DECODE(pac_reaseguro_rec.f_compania_exenta(c1.CCOMPANI,f_sysdate),'0', 1
                                                                                                                      ,'1', 0)) / 100)), '99,999,999,999,999,999,999.99') retefuente,--PENDIENTE VALIDAR PARAMETRO RETEFUENTE
											/*FIN - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                      --FIN- IAXIS-4448
                      TO_CHAR(SUM((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
                          --INI-IAXIS4448
                          /*- NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            f_sysdate,
                                            NVL(c1.preserv, 0)),0)*/
                          - ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
								  -- INICIO INFORCOL 06-02-2020 Reaseguro - Ajuste retencion local y retencion reasegurador calculo saldo		
                                  * NVL(c1.ccomrea, NVL(c1.presrea, 0)) / 100)
								  -- FIN INFORCOL 06-02-2020 Reaseguro - Ajuste retencion local y retencion reasegurador calculo saldo	
                          - ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
											/*INI - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                                  * NVL(c1.ccomrea, DECODE(pac_reaseguro_rec.f_compania_exenta(c1.CCOMPANI,f_sysdate),'0', 1
                                                                                                                      ,'1', 0)) / 100)--PENDIENTE VALIDAR PARAMETRO RETEFUENTE
											/*FIN - CJAD - 25/JULIO2019 - IAXIS4581 - Error al calcular retefuente*/
                          --fin-IAXIS4448
                          - ROUND((NVL(pac_eco_tipocambio.f_importe_cambio(v_monprod,
                                            v_moninst,
                                            cr.fefecto,
                                            NVL(cr.icesion, 0)),0) * c1.pcesion / 100)
                                  * NVL(c1.ccomrea, c1.pcomisi) / 100)), '99,999,999,999,999,999,999.99') saldo
                 FROM cesionesrea cr, cuacesfac c1, companias c2
                WHERE cr.sseguro = psseguro
                  AND cr.sproces = psproces
                  AND cr.sfacult = c1.sfacult
                  AND c2.ccompani = c1.ccompani
                  AND ((cr.ctramo = 5 AND cr.ctrampa IS NULL
                        AND NOT EXISTS (SELECT 'X' FROM cesionesrea ces2 WHERE ces2.sseguro = cr.sseguro AND ces2.ctramo = 5 AND ces2.ctrampa = 5)
                  ) OR
                         (cr.ctramo = 5 AND cr.ctrampa = 5))
                  --AND cr.ctrampa = 5
                  AND cr.nmovimi = (SELECT MAX(c3.nmovimi)
                                      FROM cesionesrea c3
                                     WHERE c3.sseguro = cr.sseguro
                                       AND c3.sproces = cr.sproces
                                       --ini IAXIS-4448
                                       AND c3.ctramo = 5
                                       --fin IAXIS-4448
                                       );				
                                       
--FIN - IAXIS-13135 FGENERA EN VES DE FEFECTO PARA CALCULO DE TRM ENDOSO
         END IF;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_reaseguro_x_garantia;


   -- INI - EDBR - 18/06/2019 -  IAXIS4330
    /*************************************************************************
    Funcion que inserta o modifica el registro de patrimoinio tecnico 
   *************************************************************************/
   FUNCTION f_set_patri_tec(
      panio NUMBER,   -- año parametrizado del patrimonio
      ptrimestre NUMBER,   -- trimestre
      pmoneda VARCHAR2,   -- moneda
      pvalor NUMBER, -- valor 
      pmovimi number)   --numero de moviento NULL nuevo registro ELSE update
      RETURN NUMBER      
      IS
      num_err        NUMBER := 0;
      v_num_movim   NUMBER ;
      v_f_ini_trim DATE;
      v_f_fin_trim DATE;
      BEGIN 
      IF panio IS NULL THEN
         num_err := 103412;
         RETURN num_err;
      END IF;


      IF ptrimestre = 1 THEN
        v_f_ini_trim := TO_DATE('01/01/'||panio,'DD/MM/YYYY');
        v_f_fin_trim := TO_DATE('31/03/'||panio,'DD/MM/YYYY');
        ELSE IF ptrimestre = 2 THEN
        v_f_ini_trim := TO_DATE('01/04/'||panio,'DD/MM/YYYY');
        v_f_fin_trim := TO_DATE('30/06/'||panio,'DD/MM/YYYY');
            ELSE IF ptrimestre = 3 THEN
            v_f_ini_trim := TO_DATE('01/07/'||panio,'DD/MM/YYYY');
            v_f_fin_trim := TO_DATE('30/09/'||panio,'DD/MM/YYYY');
            ELSE
                v_f_ini_trim := TO_DATE('01/10/'||panio,'DD/MM/YYYY');
                v_f_fin_trim := TO_DATE('31/12/'||panio,'DD/MM/YYYY');
            end if;
        END IF;
      END IF;

      IF pmovimi IS NULL THEN
        select NVL(MAX(NMOVIMI),0)+1 INTO v_num_movim from reapattec WHERE NANIO = panio AND NTRIM =ptrimestre;
      ELSE  
        v_num_movim := pmovimi; 
      END IF;
      p_control_error('dbCJ','testing INSERT', 'parámetros - panio: '|| panio || ', ptrimestre: ' || ptrimestre || ', pmoneda: '|| pmoneda || ', pvalor: ' || pvalor|| ', v_num_movim: ' || v_num_movim);
       BEGIN
         INSERT INTO REAPATTEC
                     (NANIO, NTRIM, NMOVIMI,  IPATTEC, CMONEDA, FINITRIM, FFINTRIM,FMOVINI )
              VALUES (panio, ptrimestre, v_num_movim, pvalor, pmoneda, v_f_ini_trim, v_f_fin_trim, TRUNC (SYSDATE));
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN

            UPDATE REAPATTEC r
               SET IPATTEC = pvalor,
               CMONEDA = pmoneda,
               FMOVINI = TRUNC (SYSDATE)
             WHERE r.NANIO = panio
               AND r.NTRIM = ptrimestre
               AND r.NMOVIMI = v_num_movim;
      END;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         /*p_tab_error(f_sysdate, f_user, 'pac_rea.f_set_reaformula', 2,
                     'pscontra : ' || pscontra || ' pnversio : ' || pnversio || ' pcgarant : '
                     || pcgarant || ' pccampo : ' || pccampo || ' pclave : ' || pclave,
                     SQLERRM);*/
         RETURN 108468;
      END f_set_patri_tec;
 -- FIN - EDBR - 18/06/2019 -  IAXIS4330

   /* INI - ML - 4549
    * f_activar_contrato: ACTIVA INDIVIDUALMENTE UN CONTRATO EN REASEGURO, TOMANDO LA ULTIMA VERSION VALIDA
    * RETORNA EL ESTADO DEL PROCESO, EN DONDE 0 SERIA CORRECTO Y ALGUN OTRO ES UN LITERAL DE ERROR O MENSAJE
   */
   FUNCTION f_activar_contrato(pscontra IN NUMBER)
      RETURN NUMBER IS
      num_err NUMBER := 0; -- NUMERO QUE RETORNA EL ESTADO DEL PROCESO, EN DONDE 0 SERIA CORRECTO Y ALGUN OTRO ES UN LITERAL DE ERROR O MENSAJE
      ultima_version NUMBER; -- ULTIMA VERSION REGISTRADA DEL CONTRATO
      version_anterior NUMBER; -- NUMERO DE VERSION ANTERIOR VIGENTE
      cod_empresa NUMBER; --CODIGO DE LA EMPRESA
      estado_contrato NUMBER; -- ESTADO DEL CONTRATO A ACTIVAR     
      fecha_inicio_vigencia DATE; -- FECHA DE INICIO DE VIGENCIA
   BEGIN
	   -- VERIFICAR QUE EL CONTRATO YA ESTE ACTIVO
	  BEGIN
		 SELECT CEMPRES, CVALID INTO cod_empresa, estado_contrato FROM CODICONTRATOS WHERE SCONTRA = pscontra;		   
      EXCEPTION 	   
	     WHEN NO_DATA_FOUND THEN
	  		RETURN 89907020; -- EL CONTRATO NO EXISTE
	  END;		

	  -- SI ES 0, EL CONTRATO YA ESTA ACTIVO
	  IF estado_contrato = 0 THEN
	  	RETURN 89907021; -- EL CONTRATO YA SE ENCUENTRA ACTIVO	  
	  END IF;

	  -- OBTENGO LA ULTIMA VERSION DEL CONTRATO
	  BEGIN
		  BEGIN
			SELECT MAX(nversio) INTO ultima_version FROM contratos WHERE scontra = pscontra;			
		  EXCEPTION 	   
		     WHEN NO_DATA_FOUND THEN
		  		RETURN 89907020; -- EL CONTRATO NO EXISTE
		  END;		  
		  SELECT fconini INTO fecha_inicio_vigencia FROM contratos WHERE scontra = pscontra AND NVERSIO = ultima_version;
	  EXCEPTION 	   
	     WHEN NO_DATA_FOUND THEN
	  		RETURN 89907020; -- EL CONTRATO NO EXISTE
	  END;

	   -- OBTENER VERSION ANTERIOR VIGENTE, SI NO EXISTE SE LO DEJA COMO NULL
	   BEGIN
		   SELECT nversio INTO version_anterior FROM contratos WHERE scontra = pscontra AND fconfin IS NULL;
	   EXCEPTION 	   
	     WHEN NO_DATA_FOUND THEN
	  		version_anterior := NULL;	    		    
	   END;

	  -- ACTIVAR CONTRATO MEDIANTE LOS DATOS RECOLECTADOS	  
	   RETURN F_BATCH_CESSIO (P_CEMPRES    => cod_empresa,
                                 P_SCONTRA    => pscontra,
                                 P_NVERSIOA   => version_anterior,
                                 P_NVERSION   => ultima_version,
                                 P_FEC        => fecha_inicio_vigencia);	  	   
   EXCEPTION
      WHEN OTHERS THEN 	     
         RETURN 89907022; -- ERROR AL ACTIVAR EL CONTRATO
   END f_activar_contrato; 
END pac_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REA" TO "PROGRAMADORESCSI";
