--------------------------------------------------------
--  DDL for Function F_DUPLICAR_PRODUCTO_SAVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DUPLICAR_PRODUCTO_SAVE" (
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pccolect IN NUMBER,
   pctipseg IN NUMBER,
   pcramoc IN NUMBER,
   pcmodalic IN NUMBER,
   pccolectc IN NUMBER,
   pctipsegc IN NUMBER)
   RETURN NUMBER IS
/************************************************************************************************
   F_DUPPRODUCTO    Duplica un producte ( ALBERTO )
                     Paràmetres : Pasem el SPRODUC del producte a copiar i
                                  CRAMO,CMODALI,CCOLECT,CTIPSEG del producte a copiar i del nou.

   - Se debe controlar que si es una correduría no duplique el parámetro NOVATARIFA, ya que hay
   un trigger que lo inserta automáticamente en el insert de PRODUCTOS.
   - Se copian los valores de recargo por fraccionamiento.
   - Se añaden los campos NPARBEN NBNS, CRECFRA, COFERSN en GARANPRO
   - Se añade el campo COFERSN en PREGUNPRO
   - Se añaden campos en PRODUCTOS (NDIASPRO, CPA1BEN,........)
   - Se añade el campo IMINEXT en PRODUCTOS(prima mínima extorno).
   - Se añade el campo CTARMAN en GARANPRO
   - Se añade el campo CAGRCON, CCLAPRI, CPRIMIN en PRODUCTOS.
   - Se añade el campo CCONTRA en GARANPRO
   - Se añade la tabla DETCARENCIAS
   - Se añade la tabla GARANZONA
   - Se añade la tabla GARANPROTRAMIT
   - Se añaden los campos CLIGACT, SCUECAR, IPMINFRA, NMAXRIE, IMINEXT, CCARPEN, CCLAPRI en PRODUCTOS.
   - Se añade el campo ISALMIN en PRODUCTOS_ULK.
   - Se copian las tablas clausupreg y clausugar.
   - Se añaden las tablas PROPLAPEN, PRODREPREC, PRODTRARESC i COMISIONPROD.
   - Se añaden las tablas PRODUCTO_REN y RENTASFORMULA
   - Se añaden los campos que faltan en todas las tablas.
   - Se añade el campo CCLAMIN  0026501: POSRA400-(POSRA400)-Vida Grupo (Voluntario)  (MMS - 20130328)
*************************************************************************************************/
   CURSOR cur_cla IS
      SELECT ctipcla, sclagen, norden, ccapitu, timagen, sclapro
        FROM clausupro
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect;

   CURSOR claupreg(psclapro NUMBER) IS
      SELECT cpregun, crespue
        FROM clausupreg
       WHERE sclapro = psclapro;

   CURSOR claugar(psclapro NUMBER) IS
      SELECT cgarant, cactivi, sclapro, caccion
        FROM clausugar
       WHERE sclapro = psclapro;

   numsec         NUMBER;
   v_sproduc      NUMBER;
   psproduc       NUMBER;
   lctipemp       NUMBER(2);
   vpasexec       NUMBER(8) := 1;
   vparam         VARCHAR2(2000)
      := 'pcramo' || pcramo || ' pcmodali ' || pcmodali || ' pccolect ' || pccolect
         || ' pctipseg ' || pctipseg || ' pcramoc ' || pcramoc || ' pcmodalic ' || pcmodalic
         || ' pccolectc ' || pccolectc || ' pctipsegc ' || pctipsegc;
   vobject        VARCHAR2(200) := 'f_duplicar_producto_save';
BEGIN
-- Se añaden campos en PRODUCTOS (NDIASPRO, CPA1BEN,........)
-- Se añaden los campos desde cvinpre hasta ctermfin
   BEGIN
      INSERT INTO productos
                  (ctipseg, ccolect, cramo, cmodali, cagrpro, csubpro, cactivo, ctipreb,
                   ctipges, creccob, ctippag, cpagdef, cduraci, ctempor, ctarman, ctipefe,
                   cgarsin, cvalman, ctiprie, cvalfin, cobjase, cprotec, sclaben, nedamic,
                   nedamac, nedamar, pinttec, pgasint, pgasext, iprimin, ndurcob, crecfra,
                   creteni, cimppri, cimptax, cimpcon, ccuesti, ctipcal, cimpefe, cmodelo,
                   ccalcom, creaseg, prevali, irevali, crevali, cramdgs, ctipimp, crevfpg,
                   cmovdom, sproduc, cctacor, cvinpol, cdivisa, ctipren, cclaren, nnumren,
                   cparben, ciedmac, ciedmic, ciedmar, nsedmac, cisemac, pgaexin, pgaexex,
                   cprprod, nvtomax, nvtomin, cdurmax, cligact, cpa1ren, npa1ren, tposian,
                   ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c, nedma2r, scuecar, cprorra,
                   ccompani, cprimin, cclapri, cvinpre, cdurmin, ipminfra, ndiaspro, nrenova,
                   nmaxrie, csufijo, cfeccob, nnumpag, nrecren, iminext, ccarpen, csindef,
                   ctipres, nniggar, nniigar, nparben, nbns, ctramo, cagrcon, cmodnre,
                   ctermfin)
         SELECT pctipsegc, pccolectc, pcramoc, pcmodalic, cagrpro, csubpro, cactivo, ctipreb,
                ctipges, creccob, ctippag, cpagdef, cduraci, ctempor, ctarman, ctipefe,
                cgarsin, cvalman, ctiprie, cvalfin, cobjase, cprotec, sclaben, nedamic,
                nedamac, nedamar, pinttec, pgasint, pgasext, iprimin, ndurcob, crecfra,
                creteni, cimppri, cimptax, cimpcon, ccuesti, ctipcal, cimpefe, cmodelo,
                ccalcom, creaseg, prevali, irevali, crevali, cramdgs, ctipimp, crevfpg,
                cmovdom, sproduc, cctacor, cvinpol, cdivisa, ctipren, cclaren, nnumren,
                cparben, ciedmac, ciedmic, ciedmar, nsedmac, cisemac, pgaexin, pgaexex,
                cprprod, nvtomax, nvtomin, cdurmax, cligact, cpa1ren, npa1ren, tposian,
                ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c, nedma2r, scuecar, cprorra,
                ccompani, cprimin, cclapri, cvinpre, cdurmin, ipminfra, ndiaspro, nrenova,
                nmaxrie, csufijo, cfeccob, nnumpag, nrecren, iminext, ccarpen, csindef,
                ctipres, nniggar, nniigar, nparben, nbns, ctramo, cagrcon, cmodnre, ctermfin
           FROM productos
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 110080;
   END;

   COMMIT;

   BEGIN
      INSERT INTO titulopro
                  (cramo, cmodali, ctipseg, ccolect, cidioma, ttitulo, trotulo)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cidioma, ttitulo, trotulo
           FROM titulopro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103653;
   END;

   BEGIN
      INSERT INTO forpagpro
                  (cramo, cmodali, ctipseg, ccolect, cforpag)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cforpag
           FROM forpagpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103654;
   END;

   BEGIN
      INSERT INTO comisionprod
                  (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, pcomisi)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, ccomisi, cmodcom, pcomisi
           FROM comisionprod
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112095;
   END;

   BEGIN
      INSERT INTO activiprod
                  (cramo, cmodali, ctipseg, ccolect, cactivi)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cactivi
           FROM activiprod
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 103485;
   END;

   SELECT sproduc
     INTO psproduc
     FROM productos
    WHERE cramo = pcramo
      AND cmodali = pcmodali
      AND ccolect = pccolect
      AND ctipseg = pctipseg;

   SELECT sproduc
     INTO v_sproduc
     FROM productos
    WHERE cramo = pcramoc
      AND cmodali = pcmodalic
      AND ccolect = pccolectc
      AND ctipseg = pctipsegc;

---
   BEGIN
      INSERT INTO producto_ren
                  (sproduc, ctipren, cclaren, nnumren, cparben, cligact, cpa1ren, npa1ren,
                   nrecren, cmunrec, cestmre)
         SELECT v_sproduc, ctipren, cclaren, nnumren, cparben, cligact, cpa1ren, npa1ren,
                nrecren, cmunrec, cestmre
           FROM producto_ren
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110085;
   END;

---
   BEGIN
      INSERT INTO rentasformula
                  (sproduc, ccampo, clave)
         SELECT v_sproduc, ccampo, clave
           FROM rentasformula
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110085;
   END;

-- Se añaden los campos NPARBE, NBNS, CRECFRA, COFERSN, CTARMAN
-- Se añaden los campos que faltan respecto a la tabla
   BEGIN
      INSERT INTO garanpro
                  (cmodali, ccolect, cramo, cgarant, ctipseg, ctarifa, norden, ctipgar,
                   ctipcap, ctiptar, cgardep, pcapdep, ccapmax, icapmax, icapmin, nedamic,
                   nedamac, nedamar, cformul, ctipfra, ifranqu, cgaranu, cimpcon, cimpdgs,
                   cimpips, cimpces, cimparb, cdtocom, crevali, cextrap, crecarg, cmodtar,
                   prevali, irevali, cmodrev, cimpfng, cactivi, ctarjet, ctipcal, cimpres,
                   cpasmax, cderreg, creaseg, cexclus, crenova, ctecnic, cbasica, cprovis,
                   ctabla, precseg, cramdgs, cdtoint, icaprev, ciedmac, ciedmic, ciedmar,
                   iprimax, iprimin, ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c, nedma2r,
                   sproduc, cobjaseg, csubobjaseg, cgenrie, cclacap, ctarman, cofersn,
                   nparben, nbns, crecfra, ccontra, cmodint, cpardep, cvalpar, cclamin)   -- Bug 26501 - MMS - 28/03/2013
         SELECT pcmodalic, pccolectc, pcramoc, cgarant, pctipsegc, ctarifa, norden, ctipgar,
                ctipcap, ctiptar, cgardep, pcapdep, ccapmax, icapmax, icapmin, nedamic,
                nedamac, nedamar, cformul, ctipfra, ifranqu, cgaranu, cimpcon, cimpdgs,
                cimpips, cimpces, cimparb, cdtocom, crevali, cextrap, crecarg, cmodtar,
                prevali, irevali, cmodrev, cimpfng, cactivi, ctarjet, ctipcal, cimpres,
                cpasmax, cderreg, creaseg, cexclus, crenova, ctecnic, cbasica, cprovis,
                ctabla, precseg, cramdgs, cdtoint, icaprev, ciedmac, ciedmic, ciedmar,
                iprimax, iprimin, ciema2c, ciemi2c, ciema2r, nedma2c, nedmi2c, nedma2r,
                sproduc, cobjaseg, csubobjaseg, cgenrie, cclacap, ctarman, cofersn, nparben,
                nbns, crecfra, ccontra, cmodint, cpardep, cvalpar,
                cclamin   -- Bug 26501 - MMS - 28/03/2013
           FROM garanpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102428;
   END;

   BEGIN
      INSERT INTO productos_ulk
                  (cramo, cmodali, ctipseg, ccolect, ccodfon, ndiaria, psalcue, isalcue,
                   ccapdef, ncapdef, npolhos, ncerhos, cmoneda, ndiacar, cprorat, canures,
                   cproval, isalmin)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, ccodfon, ndiaria, psalcue, isalcue,
                ccapdef, ncapdef, npolhos, ncerhos, cmoneda, ndiacar, cprorat, canures,
                cproval, isalmin
           FROM productos_ulk
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110081;
   END;

   BEGIN
      INSERT INTO garanpro_ulk
                  (cramo, cmodali, ctipseg, ccolect, cgarant, nfuncio)
         SELECT pcramoc, pcmodalic, pctipseg, pccolectc, cgarant, nfuncio
           FROM garanpro_ulk
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110083;
   END;

   BEGIN
      INSERT INTO incompgaran
                  (cramo, cmodali, ctipseg, ccolect, cgarant, cgarinc, cactivi)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cgarant, cgarinc, cactivi
           FROM incompgaran
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102429;
   END;

   FOR i IN cur_cla LOOP
      BEGIN
         SELECT sclagen.NEXTVAL
           INTO numsec
           FROM DUAL;

         INSERT INTO clausupro
                     (sclapro, ccolect, cramo, ctipseg, cmodali, ctipcla, sclagen,
                      norden, ccapitu, timagen)
              VALUES (numsec, pccolectc, pcramoc, pctipsegc, pcmodalic, i.ctipcla, i.sclagen,
                      i.norden, i.ccapitu, i.timagen);

         FOR j IN claupreg(i.sclapro) LOOP
            INSERT INTO clausupreg
                        (sclapro, cpregun, crespue)
                 VALUES (numsec, j.cpregun, j.crespue);
         END LOOP;

         FOR k IN claugar(i.sclapro) LOOP
            INSERT INTO clausugar
                        (cramo, cmodali, ctipseg, ccolect, cgarant, cactivi,
                         sclapro, caccion)
                 VALUES (pcramoc, pcmodalic, pctipsegc, pccolectc, k.cgarant, k.cactivi,
                         numsec, k.caccion);
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102427;
      END;
   END LOOP;

-- Se añade el campo COFERSN, ctabla y tvalfor
   BEGIN
      INSERT INTO pregunpro
                  (cpregun, cmodali, ccolect, cramo, ctipseg, sproduc, cpretip, npreord,
                   tprefor, cpreobl, npreimp, cresdef, cofersn, ctabla, tvalfor)
         SELECT cpregun, pcmodalic, pccolectc, pcramoc, pctipseg, v_sproduc, cpretip, npreord,
                tprefor, cpreobl, npreimp, cresdef, cofersn, ctabla, tvalfor
           FROM pregunpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102426;
   END;

   BEGIN
      INSERT INTO pargaranpro
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cpargar, cvalpar)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cactivi, cgarant, cpargar, cvalpar
           FROM pargaranpro
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110084;
   END;

   -- Se añaden los campos cofersn y ctabla
   BEGIN
      INSERT INTO pregunprogaran
                  (sproduc, cactivi, cgarant, cpregun, cpretip, npreord, tprefor, cpreobl,
                   npreimp, cresdef, cofersn, ctabla)
         SELECT v_sproduc, cactivi, cgarant, cpregun, cpretip, npreord, tprefor, cpreobl,
                npreimp, cresdef, cofersn, ctabla
           FROM pregunprogaran
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110085;
   END;

-- Si se trata de una correduría, el parámetro NOVATARIFA lo habrá
-- creado ya el trigger PRODUCTOS.PRODUCTE_NOVATARIFA
   BEGIN
      SELECT ctipemp
        INTO lctipemp
        FROM empresas
       WHERE cempres IN(SELECT cempres
                          FROM codiram
                         WHERE cramo = pcramoc);

      IF lctipemp = 1 THEN
         INSERT INTO parproductos
                     (sproduc, cparpro, cvalpar)
            SELECT v_sproduc, cparpro, cvalpar
              FROM parproductos
             WHERE sproduc = psproduc
               AND cparpro != 'NOVATARIFA';
      ELSE
         INSERT INTO parproductos
                     (sproduc, cparpro, cvalpar)
            SELECT v_sproduc, cparpro, cvalpar
              FROM parproductos
             WHERE sproduc = psproduc;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110086;
   END;

   BEGIN
      INSERT INTO garanformula
                  (cgarant, ccampo, cramo, cmodali, ctipseg, ccolect, cactivi, clave)
         SELECT cgarant, ccampo, pcramoc, pcmodalic, pctipsegc, pccolectc, cactivi, clave
           FROM garanformula
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   -- Se añade el campo Treport
   BEGIN
      INSERT INTO prodmotmov
                  (sproduc, cmotmov, tforms, norden, treport)
         SELECT v_sproduc, cmotmov, tforms, norden, treport
           FROM prodmotmov
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110088;
   END;

-- Se copian los valores de recargo por fraccionamiento.
   BEGIN
      INSERT INTO forpagrecprod
                  (cramo, cmodali, ctipseg, ccolect, cforpag, precarg)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cforpag, precarg
           FROM forpagrecprod
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110721;
   END;

   BEGIN
      INSERT INTO forpagrecacti
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cforpag, precarg)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cactivi, cforpag, precarg
           FROM forpagrecacti
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110722;
   END;

   BEGIN
      INSERT INTO forpagrecgaran
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cforpag, precarg)
         SELECT pcramoc, pcmodalic, pctipsegc, pccolectc, cactivi, cgarant, cforpag, precarg
           FROM forpagrecgaran
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 110723;
   END;

   BEGIN
      INSERT INTO detcarencias
                  (csexo, nmescar, cgarant, ccaren, sproduc, cactivi, cramo, cmodali, ctipseg,
                   ccolect)
         SELECT csexo, nmescar, cgarant, ccaren, v_sproduc, cactivi, pcramoc, pcmodalic,
                pctipsegc, pccolectc
           FROM detcarencias
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   BEGIN
      INSERT INTO garanzona
                  (sproduc, cactivi, cgarant, szonif, szona, czona)
         SELECT v_sproduc, cactivi, cgarant, szonif, szona, czona
           FROM garanzona
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

-- Se añade la tabla GARANPROTRAMIT
   BEGIN
      INSERT INTO garanprotramit
                  (sproduc, cactivi, cgarant, ctramit, cusualt, falta, cusumod, fmodif)
         SELECT v_sproduc, cactivi, cgarant, ctramit, f_user, f_sysdate, NULL, NULL
           FROM garanprotramit
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   BEGIN
      INSERT INTO proplapen
                  (sproduc, ccodpla)
         SELECT v_sproduc, ccodpla
           FROM proplapen
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112092;
   END;

   BEGIN
      INSERT INTO prodreprec
                  (sidprodp, sproduc, ctipoimp, finiefe, ffinefe, ctipnimp, cagente, ccobban)
         SELECT sidprodp.NEXTVAL, v_sproduc, ctipoimp, finiefe, ffinefe, ctipnimp, cagente,
                ccobban
           FROM prodreprec
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112093;
   END;

   BEGIN
      INSERT INTO prodtraresc
                  (sidresc, sproduc, ctipmov, finicio, ffin)
         SELECT sidresc.NEXTVAL, v_sproduc, ctipmov, finicio, ffin
           FROM prodtraresc
          WHERE sproduc = psproduc;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 112094;
   END;

   RETURN 0;
END f_duplicar_producto_save;

/

  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_PRODUCTO_SAVE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_PRODUCTO_SAVE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DUPLICAR_PRODUCTO_SAVE" TO "PROGRAMADORESCSI";
