

clear all

****************************************************
* Punto 2.1.1: Promedio de contribuciones
****************************************************
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\contributions.xlsx", firstrow clear
replace round = round[_n-1] if missing(round)
collapse (mean) contributions, by(round)

* Graficar línea y guardar
twoway line contributions round, ///
    title("Promedio de Contribuciones por Periodo") ///
    xtitle("Periodo") ///
    ytitle("Promedio de Contribuciones")
graph export "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Graphs\average_contribution.png", replace

* Guardar dataset para uso futuro
save "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Graphs\average_contribution.dta", replace

****************************************************
* Punto 2.2.1: Contribución promedio por periodo - Herrmann
****************************************************

* =========================
* SIN CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("sin_castigo") firstrow clear
drop if missing(Period)

egen mean = rowmean(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)

keep Period mean
rename mean mean_sin

tempfile sin
save `sin', replace

* =========================
* CON CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("con_castigo") firstrow clear

egen mean = rowmean(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)

keep Period mean
rename mean mean_con

merge 1:1 Period using `sin'

* =========================
* TABLA FINAL
* =========================
save "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_promedios.dta", replace
list Period mean_sin mean_con, noobs

* Cargar la tabla final
use "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_promedios.dta", clear

* Exportar a Excel
export excel Period mean_sin mean_con ///
    using "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_promedios.xlsx", ///
    firstrow(variables) replace
	
* =========================
* Gráfica contribuciones por periodo - Herrmann
* =========================

use "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_promedios.dta", clear

* Convertir a formato largo para graficar
reshape long mean_, i(Period) j(experimento) string

* Renombrar valores para que sean más claros
replace experimento = "Sin castigo" if experimento=="sin"
replace experimento = "Con castigo" if experimento=="con"
rename mean_ mean

twoway (line mean Period if experimento=="Sin castigo", lcolor(blue) lwidth(medium) lpattern(solid)) ///
       (line mean Period if experimento=="Con castigo", lcolor(red) lwidth(medium) lpattern(solid)), ///
       legend(order(1 "Sin castigo" 2 "Con castigo")) ///
       title("Contribuciones promedio por período") ///
       xtitle("Período") ///
       ytitle("Contribución promedio") 
graph export "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Graphs\grafico_promedios.png", replace

****************************************************
* Punto 2.2.2: Gráfica Periodo 1 vs 10
****************************************************

use "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_promedios.dta", clear
keep if Period == 1 | Period == 10

reshape long mean_, i(Period) j(experimento) string
replace experimento = "Sin castigo" if experimento=="sin"
replace experimento = "Con castigo" if experimento=="con"
rename mean_ mean

* Crear variable numérica para posición base (solo 1 y 2)
gen xpos_cat = .
replace xpos_cat = 1 if Period==1
replace xpos_cat = 2 if Period==10

* Ajustar posiciones para barras lado a lado
gen xpos = xpos_cat
replace xpos = xpos_cat - 0.15 if experimento == "Con castigo"
replace xpos = xpos_cat + 0.15 if experimento == "Sin castigo"

twoway ///
    (bar mean xpos if experimento=="Con castigo", barwidth(0.3) color(red)) ///
    (bar mean xpos if experimento=="Sin castigo", barwidth(0.3) color(blue)) ///
    , ///
    xlabel(1 "1" 2 "10", angle(0)) ///
    ylabel(0(5)20) ///
    legend(order(1 "Con castigo" 2 "Sin castigo")) ///
    title("Contribuciones promedio: Round 1 vs Round 10") ///
    ytitle("Contribución promedio") ///
    xtitle("Período") ///
    graphregion(color(white))
graph export "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Graphs\contribucion_promedio_rondas1&10.png", replace    

****************************************************
* Punto 2.2.3: Tabla desvicación estandar periodo 1 vs 10 
****************************************************
* =========================
* SIN CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("sin_castigo") firstrow clear
drop if missing(Period)

egen sd = rowsd(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)

keep Period sd
rename sd sd_sin

tempfile sin
save `sin'

* =========================
* CON CASTIGO
* =========================
import excel "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Data\Derived\datosHerrmann.xlsx", sheet("con_castigo") firstrow clear
drop if missing(Period)

egen sd = rowsd(Copenhagen Dnipropetrovsk Minsk StGallen Muscat Samara Zurich Boston Bonn Chengdu Seoul Riyadh Nottingham Athens Istanbul Melbourne)

keep Period sd
rename sd sd_con

merge 1:1 Period using `sin'

* =========================
* TABLA FINAL
* =========================
keep if Period==1 | Period==10
list Period sd_sin sd_con, noobs
save "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_desviaciones.dta", replace

* Abrir la tabla final
use "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_desviaciones.dta", clear

* Exportar a Excel
export excel Period sd_sin sd_con ///
    using "D:\Lina Peña\ADM\Haciendo Economía\Taller 4\Outputs\Tables\tabla_desviaciones.xlsx", ///
    firstrow(variables) replace




	
