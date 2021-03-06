##########################################################################################
# ANALIZA SKUPIEN
##########################################################################################
## Kurs:  Eksploracja danych  / data mining
## Materia�y pomocnicze do laboratorium 
## A.Suchwalko & A.Zagdanski


# Zawarto�� skryptu
# - metoda K-means
# - macierz niepodobie�stwa
# - algorytm PAM
# - metody hierarchiczne: AGNES i DIANA

##########################################################################################################
##### Metoda K-means #####################################################################################
##########################################################################################################

# K-means to jedna z najbardziej popularnych metod stosowanych w analizie skupie�
# Nale�y ona do metod grupuj�cych (ang. partitioning methods)
# Metoda ta ma jednak pewne ograniczenia i wady, np.:
# a) Dzia�a tylko dla zmiennych liczbowych  (miara niepodobie�stwa = odleg�o�� euklidesowa)
# b) Najcz�ciej wykrywa prawid�owo jedynie skupiska o kszta�tach wypuk�ych


#=== Przyk�ad: K-means dla danych o  irysach =============================================================

library(stats)

data(iris)
irysy.cechy <- iris[,1:4] # Usuwamy etykietki klas
irysy.etykietki.rzeczywiste <- iris[,5]

# Podzia� na K skupisk
k <- 3
kmeans.k3 <- kmeans(irysy.cechy,centers=k,iter.max=10)

# Etykietki grup
(irysy.etykietki.kmeans <- kmeans.k3$cluster)

# Wizualizacja wynik�w analizy skupie� (wykres rozrzutu dla zmiennych Petal.Length i Sepal.Width)
plot(irysy.cechy$Petal.Length,irysy.cechy$Sepal.Width,col=irysy.etykietki.kmeans,
pch=as.numeric(irysy.etykietki.rzeczywiste))
title("Klastrowanie z wykorzystaniem k-means \n kolor -  etykietki z k-means, symbol - etykietki rzeczywiste")

# zaznacz centra klasteryzacji
points( kmeans.k3$centers[,c("Petal.Length","Sepal.Width")],pch=16,cex=1.5,col=1:3)


#---- Przyk�ad ('Cassini problem') ----------------------------------------------------------------------
# A teraz przyk�ad danych, z kt�rymi k-means nie radzi sobie najlepiej ...
# Cassini problem: Skupisko o kszta�cie sferycznym wewn�trz 2 skupisk o kszta�tach bananowych

library(mlbench)
dane.cassini <- mlbench.cassini(n=2000)
plot(dane.cassini)
title('Cassini problem')

dane  <- dane.cassini$x
klasy <- dane.cassini$clases


kmeans.cassini3 <- kmeans(dane,centers=3,iter.max=10,nstart=1)
plot(dane,col=kmeans.cassini3$cluster)
title('Cassini problem: wynik metody k-means')

# �wiczenia
# 1) Powt�rz kilkukrotnie powy�sz� analiz�, obserwuj�c, jak zmienia si� rezultat (=otrzymana partycja)
# 2) Przeprowad� podobne eksperymenty jak w punkcie 1), tym razem dla innej ni� k=3
# liczby klastr�w  (np. k=4,5,6)


# Analiza dla 10-ciu losowych inicjalizacji metody k-means
kmeans.cassini3.10x <- kmeans(dane,centers=3,iter.max=10,nstart=10)
plot(dane,col=kmeans.cassini3.10x$cluster)
title('Cassini problem: wynik metody k-means (10 inicjalizacji)')
# Czy teraz uda�o sie znale�� prawdziw� struktur� danych?


######################################################################################################
####### Algorytm  PAM (Partitioning Around Medoids) ##################################################
######################################################################################################

# Metoda PAM jest bardziej og�lna ni� K-means
# Dzia�a dla zmiennych dowolnych typ�w (tzn. dla dowolnej macierzy niepodobie�stwa)
# Centrami skupisk s� nie �rednie a "medoidy" (obiekty-reprezentanci)
#  wybrane spo�r�d wszystkich obiekt�w znajduj�cych si� w naszym zbiorze danych

# Wczytanie niezb�dnych bibliotek
library(MASS)
library(cluster)
data(Cars93)


#=== Przyklad: Cars93 - wszystkie cechy ===============================================================
# Wyznaczenie macierzy podobie�stwa/niepodobie�stwa pomi�dzy obiektami
# jest kluczowe dla analizy skupie� i cz�sto wa�niejsze od samego wyboru metody (algorytmu) podzia�u na grupy!
# Aby zrobi� to poprawnie powinni�my zorientowa� si�, jakie typu s� nasze zmienne (cechy), tzn.
# liczbowe, nominalne, binarne, itd.


# Na pocz�tek: usuwamy zmienne "Model" i "Make"
# kazdy samoch�d ma r�n� warto��, wiec s� nieprzydatne do oceny  podobie�stwa
  rownames(Cars93) <- Cars93$Make
  wybraneCechy <- setdiff(colnames(Cars93),c("Model","Make"))
 Cars93.wybrane <- Cars93[,wybraneCechy]
 samochody.MacNiepodob <- daisy(Cars93.wybrane)

# Konwersja do macierzy
 samochody.MacNiepodob.matrix <- as.matrix(samochody.MacNiepodob)


Cars93.pam3 <- pam(x=samochody.MacNiepodob,diss=TRUE,k=3)
X11()
plot(Cars93.pam3)


#  Uwaga
#  Obiekt  Cars93.pam3 zawiera informacje o poszczeg�lnych klastrach, w tym m.in.:
#  rozmiar(size), maksymalna i �rednia warto�� niepodobie�stwa (max_diss,av_diss),
#  �rednica (diameter), separacja  (separation),
#  informacja o L- i L*-klastrach,
#  warto�ci 'silhouette' dla poszczeg�lnych obiekt�w
#  (Szczeg�owy opis  wska�nik�w --> patrz wyk�ad lub help)

(summary(Cars93.pam3))

# Przyk�adowa wizualizacja wynik�w w 2D  (kolor = etykietka klastra)
X11()
etykietki <- Cars93.pam3$clustering
plot(Cars93$Horsepower,Cars93$Price,col=etykietki,xlab="Moc",ylab="Cena")
title("Dane Cars93 -- wizualizacja wynikow analizy skupien")

# Mo�emy sprawdzi�, kt�re obiekty s� centrami skupisk czyli s� reprezentatywne dla danego skupiska
CentraSkupisk.nazwy <- Cars93.pam3$medoids

# �wiczenie (Interpretacja wynik�w analizy skupie�)
# Przeanalizuj jakie samochody znalaz�y si� w poszczeg�lnych skupieniach
# Mo�na np. przeanalizowa� w poszczeg�lnych skupieniach: warto�ci �rednie dla  cech numerycznych lub
# liczno�ci (funkcja "table") dla cech jako�ciowych


#=== Przyk�ad: Cars93 - Wybieramy tylko zmienne liczbowe (typ==numeric) ============================================
Cars93.CechyLiczbowe <- Cars93[,names(unlist(lapply(Cars93,FUN=function(x) if(is.numeric(x)) "numeric" else NULL)))]
Cars93.numeric.pam3 <- pam(Cars93.CechyLiczbowe,k=3,metric="euclidean")

(summary(Cars93.numeric.pam3))

# Wizualizacja wynik�w
plot(Cars93.numeric.pam3)
# W tym przypadku, opr�cz wykres�w silhouette pojawia si� r�wnie� wizualizacja wynik�w analizy skupie�
# z wykorzystaniem PCA


############################################################################################################
############## Metody hierarchiczne: AGNES,DIANA ###########################################################
############################################################################################################

#============== AGNES (Aglomerative Nesting) =============================================

# Trzy metody ��czenia klastrow (ang. linkage method)
# method = 'average'  (�rednia odleg�o��)
# method = 'complete' (najdalszy s�siad)
# method = 'single'   (najbli�szy s�siad)

Cars93.agnes.avg <- agnes(x=samochody.MacNiepodob,diss=TRUE,method="average")
Cars93.agnes.single <- agnes(x=samochody.MacNiepodob,diss=TRUE,method="single")
Cars93.agnes.complete <- agnes(x=samochody.MacNiepodob,diss=TRUE,method="complete")


#--- Wizualizacja (dendrogram, clustering tree) ------------------------------------------

X11()
par(cex=0.6)
plot(Cars93.agnes.avg,which.plots=2,main="AGNES: average linkage")

X11()
par(cex=0.6)
plot(Cars93.agnes.single,which.plots=2,main="AGNES: single linkage")

X11()
par(cex=0.6)
plot(Cars93.agnes.complete,which.plots=2, main="AGNES: complete linkage")


# �wiczenia
# 1) Por�wnaj skonstruowane dendrogramy
# 2) Kt�ra metoda ��czenia klastrow wydaje si� najlepsza?

#--- Odcinanie drzewa klastrow (dedrogramu) dla zadanej liczby klastr�w  -----------------------------
Cars93.agnes.avg.k2 <- cutree(Cars93.agnes.avg,k=2) # etykietki klastrow

#--- Wska�niki silhouette dla metod hierarchicznych --------------------------------------------------

sil.agnes <- silhouette(x=Cars93.agnes.avg.k2,dist=samochody.MacNiepodob)
# �redni� warto�� silhouette dla ka�dego klastra mo�emy otrzyma� nast�puj�co
(sil.srednie.w.klastrach <- summary(sil.agnes)$clus.avg.widths)

# Uwaga
# Podobnie jak dla PAM i K-means mo�emy wybra� opytymaln� liczb� klastr�w, kt�ra maksymalizuje sredni�
# warto�� silhouette

#=========== DIANA (Divisive clustering) ===========================================
Cars93.diana <- diana(x=samochody.MacNiepodob,diss=TRUE)
X11()
par(cex=0.6)
plot(Cars93.diana,which.plot=2, main="DIANA")

# Odcinamy drzewo tak aby uzyskac dokladnie K=3 klastry
(Cars93.diana.k3 <- cutree(Cars93.diana,k=3)) # etykietki klastrow


#========== Przyklad1: Dane o zwierz�tach ==========================================
# Wczytanie danych
require(cluster)
data(animals)

# Zamiana na zmienne logiczne i obiekt typu data.frame
 {animals==2} -> animals1
 animals.df <- data.frame(animals1)

# Wyznaczenie macierzy (nie)podobie�stwa (wszystkie zmienne s� zmiennymi binarnymi - symetrycznymi ! )
daisy(animals.df,type=list(symm=1:6)) -> dis.matrix

animals.agnes <- agnes(dis.matrix,method="average",diss=T)

# wykres: clustering tree + banner
 plot(animals.agnes)

# �wiczenia
# 1) Por�wnaj wyniki analizy skupie� dla
#    a) metody AGNES  wykorzystuj�cej inne ni� 'average' metody ��czenia klastr�w
#       (tzn. method = 'complete' i method = 'single')
#    b) hierarchicznej metody rozdzielaj�cej (DIANA)
#    c) metody grupuj�cej PAM
# 2) Zaproponuj metod�  wyboru optymalnej liczby klastr�w   dla tego zbioru danych
#
