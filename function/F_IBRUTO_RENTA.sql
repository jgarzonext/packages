--------------------------------------------------------
--  DDL for Function F_IBRUTO_RENTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IBRUTO_RENTA" (psseguro IN NUMBER, pfecha IN DATE   -- FECHA DE CALCULO
                                                                            )
   RETURN NUMBER IS
   viprimuni      NUMBER;   -- PRIMA UNICA ( Provisió matematica el dia abans del venciment de la polissa)
   vctiptab       NUMBER;   -- CODI DE LA TAULA DE MORTALITAT SEGONS EL PRODUCTE
   vpinttec       NUMBER;   -- INTERES TECNICO QUE SE APLICA (A NIVEL  DE PRODUCTO )
   vpgasint       NUMBER;   -- PORCENTAGE DE GASTOS INTERNOS A NIVEL DE PRODUCTO.
   vnduraci       NUMBER;   -- DURACIÓN EN MESES DE LA PÒLIZA
   vfvencim       DATE;   -- DATA DE VENCIMENT.
   vindice        NUMBER := 0;   -- 0.. N MESES DE DURACIÓN DE LA POLIZA
   vaÑoreserva    NUMBER;   -- AÑO DE INICIO DEL CALCULO
   vanyo          NUMBER := 0;   -- AÑO DE CALCULO
   vfcarult       DATE;   -- FECHA A PARTIR DE LA CUAL HAY IMPORTE BRUTO DE LA RENTA
   vsexo          NUMBER;   -- SEXO DEL PRIMER ASEGURADO
   vedad          NUMBER;   -- EDAD DEL PRIMER ASEGURADO
   vfnacimi       DATE;   -- FECHA NACIMIENTO DEL PRIMER ASEGURADO
   vfefecto       DATE;   -- FECHA EFECTO DE LA POLIZA
   vactuarial     NUMBER;   -- EDAD ACTUARIAL
   vcdivisa       VARCHAR2(6);   -- DIVISA
   /* VALORES DE LA TABLA DE MORTALIDAD  */
   p_factor       NUMBER;   -- Valor en la taula de mortalitat de l'VEDAD de càlcul pel primer assegurat
   p_factorseg    NUMBER;   -- Valor en la taula de mortalitat de l'VEDAD de càlcul pel segon assegurat
   p_factor1      NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Primer assegurat)
   p_factor1seg   NUMBER;   -- Valor en la taula de mort. de l'edat + 1 on ens troven fent el càlcul(Segon assegurat)
   vanyories      NUMBER;
   var_lx1        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Primer assegurat)
   var_lx2        NUMBER;   -- Valor en la taula de mort. de l'edat on ens troven fent el càlcul (Segon assegurat)
   vvecvida       NUMBER;   -- Sumatori del vector vida.
   num_err        NUMBER;   -- Control d'erors
   resultado      NUMBER;
   vigas          NUMBER;
   vaux           NUMBER;
   vagente_poliza seguros.cagente%TYPE;
   vcempres       seguros.cempres%TYPE;
BEGIN
   vindice := 0;

   -- BORRAMOS LOS DATOS DE LA TABLA MATRIZPROVMATGEN
   DELETE FROM matrizprovmatgen;

   -- SELECCIONAMOS EL INTERES Y GASTOS QUE SE APLICAN
   SELECT p.pgasint, p.pinttec, DECODE(p.cdivisa, 2, 'PTS', 3, 'EUR', '??'), pr.nnumren
     INTO vpgasint, vpinttec, vcdivisa, vnduraci
     FROM productos p, seguros s, producto_ren pr
    WHERE p.cramo = s.cramo
      AND p.sproduc = pr.sproduc
      AND p.ctipseg = s.ctipseg
      AND p.ccolect = s.ccolect
      AND p.cmodali = s.cmodali
      AND s.sseguro = psseguro;

   -- CODIGO DE LA TABLA
   SELECT g.ctabla
     INTO vctiptab
     FROM garanpro g, seguros s
    WHERE g.ctabla IS NOT NULL
      AND g.cramo = s.cramo
      AND g.cmodali = s.cmodali
      AND g.ctipseg = s.ctipseg
      AND g.ccolect = s.ccolect
      AND s.sseguro = psseguro;

   -- SELECCIONAMOS LOS DATOS DEL SEGURO
   SELECT fefecto, vnduraci, fvencim, cagente, cempres
     INTO vfefecto, vnduraci, vfvencim, vagente_poliza, vcempres
     FROM seguros
    WHERE sseguro = psseguro;

   -- SELECCIONAMOS LOS DATOS DEL PRIMER ASEGURADO
   SELECT p.csexper, p.fnacimi
     INTO vsexo, vfnacimi
     FROM asegurados a, per_personas p
    WHERE a.sseguro = psseguro
      AND a.norden = 1
      AND p.sperson = a.sperson;

    /*-- SELECCIONAMOS LOS DATOS DEL PRIMER ASEGURADO
   SELECT P.CSEXPER , P.FNACIMI
    INTO vsexo, VFNACIMI
   FROM ASEGURADOS A, PERSONAS P
   WHERE A.SSEGURO= PSSEGURO
         AND A.NORDEN = 1
        AND P.SPERSON = A.SPERSON;*/
   SELECT f1paren
     INTO vfcarult
     FROM seguros_ren
    WHERE sseguro = psseguro;

   -- CALCULAMOS LA PRIMA UNICA QUE SERA LA PROVISIÓN MATEMATICA EL DIA DE ANTES DE LA FECHA DE VENCIMIENTO
   viprimuni := pk_provmatematicas.f_provmat(1, psseguro, vfcarult - 1, 1, 0);
   -- VEDAD EN MESES DEL PRIMER ASEGURADO
   vedad := ROUND(((vfcarult - vfnacimi) / 365.25) * 12);

   -- CALCULAMOS LA DURACIÓN DE LA POLIZA EN MESES DESDE LA FECHA EN QUE COMIENZA A PAGARSE EL IMPORTE BRUTO
   -- DE LA RENTA HASTA LA FECHA FENCIMIENTO.
   IF vnduraci IS NULL THEN
      vnduraci :=(((TO_NUMBER(TO_CHAR(vfvencim, 'yyyy')) * 12)
                   + TO_NUMBER((TO_CHAR(vfvencim, 'MM'))))
                  -((TO_NUMBER(TO_CHAR(vfcarult, 'yyyy')) * 12)
                    + TO_NUMBER((TO_CHAR(vfcarult, 'MM')))));
   END IF;

   -- AÑO ACTUARIAL
   vanyories := ((TO_NUMBER(TO_CHAR(pfecha, 'YYYY')) * 12) + TO_NUMBER((TO_CHAR(pfecha, 'MM'))))
                -((TO_NUMBER(TO_CHAR(vfefecto, 'YYYY')) * 12)
                  + TO_NUMBER((TO_CHAR(vfefecto, 'MM'))));

   -- CALCULAMOS EL VALOR DE MORTALIDAD PARA LA EDAD DEL PRIMER ASEGURADO
   SELECT DECODE(vsexo, 1, vmascul, 2, vfemeni, 0)
     INTO p_factor
     FROM mortalidad
    WHERE nedad = vedad
      AND ctabla = vctiptab;

   -- CALCULOS ANTES DEL AÑO DE CALCULO: SOLO TENEMOS PROBABILIDADES
   vanyories := vanyo;
   vanyo := 0;

   DELETE FROM matrizprovmatgen;

   -- Calculem el valor de la taula de mortalitat per l'edat del primer assegurat
   SELECT DECODE(vsexo, 1, vmascul, 2, vfemeni, 0)
     INTO p_factor
     FROM mortalidad
    WHERE nedad = vedad
      AND ctabla = vctiptab;

   -- Calculs abans de l'any de calcul: Només tindrem les probabilitats.
   FOR anyo IN 0 ..(vanyories - 1) LOOP
      -- Seleccionem el valor en la taula de mortalitat que correspon
      -- a l'edat en l'any en el que fem els calculs.
      BEGIN
         SELECT DECODE(vsexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor1
           FROM mortalidad
          WHERE nedad = vedad + 1
            AND ctabla = vctiptab;

         SELECT DECODE(vsexo, 1, vmascul, 2, vfemeni, 0)
           INTO var_lx1
           FROM mortalidad
          WHERE nedad = vedad
            AND ctabla = vctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO matrizprovmatgen
                     (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2, tpxi,
                      tsumpx1, tsumpx2, tsumpxi, tqx, vn, vn2, vecvida, vecmort, icapital,
                      itotprim, igascapv, ipgascapv, ipcmort, ippmort, ipcvid, ippvid, sproces)
              VALUES (vindice, vedad, NULL, NULL, var_lx1, NULL, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 1);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vindice := vindice + 1;
      vedad := vedad + 1;
   END LOOP;

   -- A PARTIR DEL AÑO DE CALCULO
   vaÑoreserva := 0;
   vanyo := vanyories;
   -- VALORES DE MORTALIDAD PARA LA EDAD DEL ASEGURADO EN EL AÑO DE  CALCULO
   p_factor := 0;
   p_factorseg := 0;

   SELECT DECODE(vsexo, 1, vmascul, 2, vfemeni, 0)
     INTO p_factor
     FROM mortalidad
    WHERE nedad = vedad
      AND ctabla = vctiptab;

   vactuarial := 0;

   FOR anyo IN vanyories .. vnduraci LOOP
      vanyories := 0;

      BEGIN
         var_lx1 := 0;

         SELECT DECODE(vsexo, 1, vmascul, 2, vfemeni, 0)
           INTO var_lx1
           FROM mortalidad
          WHERE nedad = vedad
            AND ctabla = vctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         p_factor1 := 0;
         p_factor1seg := 0;

         SELECT DECODE(vsexo, 1, vmascul, 2, vfemeni, 0)
           INTO p_factor1
           FROM mortalidad
          WHERE nedad = vedad + 1
            AND ctabla = vctiptab;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      BEGIN
         INSERT INTO matrizprovmatgen
                     (cindice, nmeses1, nmeses2, nanyosries, lx1, lx2, tpx1, tpx2,
                      tpxi, tsumpx1, tsumpx2, tsumpxi, tqx,
                      vn,
                      vn2,
                      vecvida,
                      vecmort, icapital, itotprim, igascapv, ipgascapv, ipcmort, ippmort,
                      ipcvid, ippvid, sproces)
              VALUES (vindice, vedad, NULL, vactuarial, var_lx1, NULL, var_lx1 / p_factor,   -- TPX1
                                                                                          0,   --TPX2  (No existeix : Només tenim un assegurat )
                      var_lx1 / p_factor,   -- TPXI
                                         0,   -- TSUMPX1
                                           0,   -- TSUMPX2
                                             0,   -- TSUMPXI
                                               0,   -- TQX
                      POWER((1 +((POWER((1 +(vpinttec / 100)),(1 / 12))) - 1)), -vañoreserva),   --VN
                      0,   -- VN2
                      ((var_lx1 / p_factor)
                       *(POWER((1 +((POWER((1 +(vpinttec / 100)),(1 / 12))) - 1)),
                               -vañoreserva))),   -- VECVIDA ((p_factor1/p_factor)*(  POWER((1 + ((POWER( (1+(pinttec/100)),(1/12)))-1) ),- añoreserva)))
                      0,   -- VECMORT
                        0,   -- ICAPITAL
                          0,   -- ITOTPRIM
                            0,   -- IGASCAPV
                              0,   -- IPGASCAPV
                                0,   -- IPPCMORT
                                  0,   -- IPPMORT
                      0,   -- IPCVID
                        0,   -- IPPVID
                          1);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vindice := vindice + 1;
      vaÑoreserva := vaÑoreserva + 1;
      vactuarial := vactuarial + 1;
      vedad := vedad + 1;
   END LOOP;

   num_err := 0;
   -- Tenim el sumatori del vector vida
   vvecvida := 0;

   SELECT SUM(vecvida)
     INTO vvecvida
     FROM matrizprovmatgen;

   -- PROVISIÓN POR GASTOS
   UPDATE matrizprovmatgen
      SET igascapv =(vpgasint / 100);

   FOR i IN 0 .. vnduraci LOOP
      BEGIN
         -- Provisió per gastos mientras viva.( Antes del año de calculo 0,(El vector vida sera cero))
         UPDATE matrizprovmatgen
            SET ipgascapv = (SELECT (vecvida * igascapv)
                               FROM matrizprovmatgen
                              WHERE sproces = 1
                                AND cindice = i)
          WHERE sproces = 1
            AND cindice = i;
      EXCEPTION
         WHEN OTHERS THEN
            --DBMS_OUTPUT.put_line('ERROR ::  ' || SQLERRM);
            EXIT;
      END;
   END LOOP;

   SELECT SUM(ipgascapv)
     INTO resultado
     FROM matrizprovmatgen
    WHERE sproces = 1;

   resultado := viprimuni /(resultado + vvecvida);

   IF vcdivisa = 'PTS' THEN
      RETURN ROUND(resultado);
   ELSIF vcdivisa = 'EUR' THEN
      RETURN f_round(resultado);
   ELSIF vcdivisa = '??' THEN
      RETURN resultado;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('ERROR : ' || SQLCODE || '  ' || SQLERRM);
      RETURN(-1);
END f_ibruto_renta;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IBRUTO_RENTA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IBRUTO_RENTA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IBRUTO_RENTA" TO "PROGRAMADORESCSI";
