/*=============================================================
  TALLER 4 - EXPERIMENTOS: PUNTOS FALTANTES
  Puntos: 2.2.4, 2.2.5, 2.3.2, 2.3.3
=============================================================*/

******************
* Punto 2.2.4: Máximo y mínimo - Periodos 1 y 10
******************

* =========================
* SIN CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("sin_castigo") firstrow clear
drop if missing(Period)

* Calcular max y min entre ciudades (por fila) para cada período
egen maxval = rowmax(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen minval = rowmin(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)

keep Period maxval minval
rename maxval max_sin
rename minval min_sin

* Filtrar solo los periodos de interés
keep if Period == 1 | Period == 10

tempfile sin_maxmin
save `sin_maxmin', replace

* =========================
* CON CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("con_castigo") firstrow clear
drop if missing(Period)

egen maxval = rowmax(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen minval = rowmin(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)

keep Period maxval minval
rename maxval max_con
rename minval min_con

keep if Period == 1 | Period == 10

merge 1:1 Period using `sin_maxmin'

* =========================
* TABLA Y EXPORTACIÓN
* =========================
drop _merge
list Period min_sin max_sin min_con max_con, noobs

save "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_maxmin.dta", replace

export excel Period min_sin max_sin min_con max_con ///
    using "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_maxmin.xlsx", ///
    firstrow(variables) replace


******************
* Punto 2.2.5: Tabla de estadísticas descriptivas completa
* (media, varianza, DE, mínimo, máximo, rango)
* Para Periodos 1 y 10 en ambos experimentos
******************

* =========================
* SIN CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("sin_castigo") firstrow clear
drop if missing(Period)
keep if Period == 1 | Period == 10

* Calcular estadísticos fila a fila (entre ciudades)
egen mean_sin  = rowmean(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen sd_sin    = rowsd(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen max_sin   = rowmax(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen min_sin   = rowmin(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
gen  var_sin   = sd_sin^2
gen  range_sin = max_sin - min_sin

keep Period mean_sin sd_sin var_sin min_sin max_sin range_sin

tempfile sin_desc
save `sin_desc', replace

* =========================
* CON CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("con_castigo") firstrow clear
drop if missing(Period)
keep if Period == 1 | Period == 10

egen mean_con  = rowmean(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen sd_con    = rowsd(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen max_con   = rowmax(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
egen min_con   = rowmin(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)
gen  var_con   = sd_con^2
gen  range_con = max_con - min_con

keep Period mean_con sd_con var_con min_con max_con range_con

merge 1:1 Period using `sin_desc'
drop _merge

* Ordenar columnas para presentación clara
order Period ///
    mean_sin var_sin sd_sin min_sin max_sin range_sin ///
    mean_con var_con sd_con min_con max_con range_con

* Mostrar en consola
list Period ///
    mean_sin var_sin sd_sin min_sin max_sin range_sin ///
    mean_con var_con sd_con min_con max_con range_con, noobs

save "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_descriptiva.dta", replace

export excel Period ///
    mean_sin var_sin sd_sin min_sin max_sin range_sin ///
    mean_con var_con sd_con min_con max_con range_con ///
    using "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_descriptiva.xlsx", ///
    firstrow(variables) replace


******************
* Punto 2.3.2: t-test diferencia de medias - Periodo 1
******************

* Cargar datos de ambos experimentos y reestructurar para t-test
* El t-test compara las 16 contribuciones de ciudades en Período 1
* entre el experimento con castigo y sin castigo

* --- Sin castigo - Período 1 ---
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("sin_castigo") firstrow clear
drop if missing(Period)
keep if Period == 1

* Convertir de formato ancho a largo (una fila por ciudad)
reshape long , i(Period) j(ciudad) string
* Nota: si reshape no funciona por nombres de variables, usar:
* stack Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne, into(contribucion ciudad) clear

* Alternativa robusta: transponer manualmente con stack
stack Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne, into(contribucion ciudad) clear
gen castigo = 0        // 0 = sin castigo
tempfile sin_p1
save `sin_p1', replace

* --- Con castigo - Período 1 ---
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("con_castigo") firstrow clear
drop if missing(Period)
keep if Period == 1

stack Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne, into(contribucion ciudad) clear
gen castigo = 1        // 1 = con castigo

append using `sin_p1'

* --- Ejecutar t-test ---
* H0: media_con = media_sin  |  H1: media_con ≠ media_sin
ttest contribucion, by(castigo)

/*
INTERPRETACIÓN ESPERADA (P2.3.2):
  - Si p-valor > 0.05: No rechazamos H0. Las medias del Período 1 NO son
    significativamente distintas. Esto confirma que ambos grupos partieron
    de condiciones similares, lo que valida la comparación causal posterior.
  - Si p-valor < 0.05: Habría diferencia inicial, lo que podría comprometer
    la atribución causal del castigo sobre el comportamiento.
*/


******************
* Punto 2.3.3: t-test diferencia de medias - Periodo 10
******************

* --- Sin castigo - Período 10 ---
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("sin_castigo") firstrow clear
drop if missing(Period)
keep if Period == 10

stack Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne, into(contribucion ciudad) clear
gen castigo = 0
tempfile sin_p10
save `sin_p10', replace

* --- Con castigo - Período 10 ---
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("con_castigo") firstrow clear
drop if missing(Period)
keep if Period == 10

stack Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne, into(contribucion ciudad) clear
gen castigo = 1

append using `sin_p10'

* --- Ejecutar t-test ---
ttest contribucion, by(castigo)

/*
INTERPRETACIÓN ESPERADA (P2.3.3):
  - Si p-valor < 0.05: Rechazamos H0. Las contribuciones promedio en el
    Período 10 SÍ son significativamente distintas entre ambos experimentos.
    Esto sugiere que el castigo tuvo un efecto real sobre el comportamiento
    y que la diferencia observada no se debe simplemente al azar.
  - Si p-valor > 0.05: No podríamos concluir que la diferencia es
    estadísticamente significativa con los datos disponibles.

  NOTA sobre Figuras 2.7 y 2.8 (referencia en el enunciado):
    No podemos usar solo el tamaño de la diferencia para concluir causalidad
    porque una diferencia grande podría surgir por azar si la variabilidad
    dentro de cada grupo también es grande. El p-valor del t-test combina
    tanto el tamaño de la diferencia como la dispersión de los datos,
    permitiendo una conclusión estadísticamente fundamentada.
*/
