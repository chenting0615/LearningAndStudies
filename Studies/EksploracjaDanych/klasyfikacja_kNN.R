##########################################################################################
# KLASYFIKACJA  na przyk�adzie metody k-NN (k-Nearest Neighbors)
##########################################################################################
## Kurs: Eksploracja danych / data mining
## Materia�y pomocnicze do laboratorium 
## (C) A.Zagdanski & A.Suchwalko


# Zajmiemy si� analiz� danych dotycz�cych irys�w. Zach�camy do samodzielnej pracy z trudniejszymi zbiorami danych
# oraz do stawiania w�asnych problem�w, kt�re mog� by� rozwi�zane z wykorzystaniem metod klasyfikacji.
#
# Przyk�ady ciekawych danych do wykorzystania w przyk�adach:
#  -- {painters}{MASS}
#  -- {PimaIndiansDiabetes}{mlbench}
#  -- {BreastCancer}{mlbench}
#  -- {Glass}{mlbench}
#  -- {spam}{ElemStatLearn}

library(MASS)
data(iris)


############################################################################################
#### Przed budow� modeli klasyfikacyjnych nale�y przyjrze� si� danym (analiza opisowa)
#
# W szczeg�lno�ci wykonujemy analizy jedno- i dwuwymiarowe dla danych pogrupowanych: 
#  -- wykresy pude�kowe, 
#  -- histogramy, 
#  -- wykresy rozrzutu, 
#  -- korelacje,
#  -- ....


############################################################################################
#### klasyfikacja obiekt�w na przyk�adzie metody k-nn  z pakietu class

library(class)

# losowanie podzbior�w
n <- dim(iris)[1]

# losujemy obiekty do zbioru ucz�cego i testowego
learning.set.index <- sample(1:n,2/3*n)

# tworzymy zbi�r ucz�cy i testowy
learning.set <- iris[learning.set.index,]
test.set     <- iris[-learning.set.index,]

# rzeczywiste gatunki irys�w
etykietki.rzecz <- test.set$Species

# teraz robimy prognoz�
etykietki.prog <- knn(learning.set[,-5], test.set[,-5], learning.set$Species, k=5)

# tablica kontyngencji
(wynik.tablica <- table(etykietki.prog,etykietki.rzecz))

# b��d klasyfikacji
n.test <- dim(test.set)[1]

(n.test - sum(diag(wynik.tablica))) / n.test


# Uda�o si�, ale to nie jest najlepsza metoda. 
# Wady funkcji knn{class}:
#  * trudno jest wybiera� cechy,  
#  * w R zazwyczaj modele klasyfikacyjne buduje si� inaczej, �atwiej wtedy wida�, na czym polega budowa i ocena
#     jako�ci modeli klasyfikacyjnych.



############################################################################################
#### Idea budowy modeli klasyfikacyjnych w R na przyk�adzie metody k-nn z pakietu ipred 

# Uwaga: 
# Implementacja w pakiecie "ipred" znacznie bardziej zbli�ona jest do standardowej implementacji
# modeli klasyfikacyjnych w systemie R.

library(ipred)

# budujemy model
model.knn.1 <- ipredknn(Species ~ ., data=learning.set, k=5)

# zobaczmy, co jest w �rodku
model.knn.1
summary(model.knn.1)
attributes(model.knn.1)

# sprawd�my jako�� modelu
# uwaga: czasami funkcje "predict" dzia�aj� niestandardowo
etykietki.prog <- predict(model.knn.1,test.set,type="class")

# tablica kontyngencji
(wynik.tablica <- table(etykietki.prog,etykietki.rzecz))

# b��d klasyfikacji
(n.test - sum(diag(wynik.tablica))) / n.test

# mo�na r�wnie� skonstruowa� model oparty na innych zmiennych oraz bazuj�cy na innej liczbie s�siad�w
# i sprawdzi� jego jako��:
model.knn.2 <- ipredknn(Species ~ Petal.Length + Petal.Width, data=learning.set, k=5)
model.knn.3 <- ipredknn(Species ~ Sepal.Length + Sepal.Width, data=learning.set, k=5)



############################################################################################
#### Inne (zaawansowane) sposoby oceny jako�ci klasyfikacji

# Cz�sto stosuje sie metod� cross-validation polegaj�c� na wielokrotnym losowaniu zbioru ucz�cego i testowego, budowie klasyfikatora
# na zbiorze ucz�cym, sprawdzenia go na testowym oraz u�rednieniu wynik�w.

# Oczywi�cie, da si� zrobi� wszystko "na piechot�" w p�tli i u�redni�, ale mo�na zrobi� to znacznie pro�ciej...

library(ipred)

# �eby skorzysta� z gotowych funkcji nale�y przygotowa� sobie "wrapper" dostosowuj�cy
# funkcj� "predict" dla naszego modelu do standardu wymaganego przez "errorest"

my.predict  <- function(model, newdata) predict(model, newdata=newdata, type="class")
my.ipredknn <- function(formula1, data1, ile.sasiadow) ipredknn(formula=formula1,data=data1,k=ile.sasiadow)

# porownanie b��d�w klasyfikacji: cv, boot, .632plus
errorest(Species ~., iris, model=my.ipredknn, predict=my.predict, estimator="cv",     est.para=control.errorest(k = 10), ile.sasiadow=5)
errorest(Species ~., iris, model=my.ipredknn, predict=my.predict, estimator="boot",   est.para=control.errorest(nboot = 10), ile.sasiadow=5)
errorest(Species ~., iris, model=my.ipredknn, predict=my.predict, estimator="632plus",est.para=control.errorest(nboot = 10), ile.sasiadow=5)


############################################################################################
#### Obszary decyzyjne (dla wybranych par zmiennych)

library(klaR)

levels(iris$Species) = c("A","B","C") #"setosa"     "versicolor" "virginica"

drawparti( iris$Species, x=iris$Petal.Length, y=iris$Petal.Width, method = "sknn", k=1,  xlab="PL",ylab="PW")
drawparti( iris$Species, x=iris$Petal.Length, y=iris$Petal.Width, method = "sknn", k=15,  xlab="PL",ylab="PW")

partimat(Species ~ ., data = iris, method = "sknn",  plot.matrix = FALSE, imageplot = TRUE)