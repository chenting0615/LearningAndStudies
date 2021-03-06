##########################################################################################
# DRZEWA KLASYFIKACYJNE
##########################################################################################
## Kurs: Eksploracja danych  / data mining
## Materia�y pomocnicze do laboratorium 
## (C) A.Zagdanski & A.Suchwalko

library(MASS)
data(iris)

# losowanie podzbior�w
n <- dim(iris)[1]

# losujemy obiekty do zbioru ucz�cego i testowego
learning.set.index <- sample(1:n,2/3*n)

# tworzymy zbi�r ucz�cy i testowy
learning.set <- iris[learning.set.index,]
test.set     <- iris[-learning.set.index,]
n.test <- dim(test.set)[1]

# rzeczywiste gatunki irys�w
etykietki.rzecz <- test.set$Species

############################################################################################
#### drzewa klasyfikacyjne

# Uwaga: Drzewa klasyfikacyjne maj� wiele parametr�w, kt�re mo�na ustawia�. 
# Co wi�cej, w systemie R mamy wiele implementacji algorytm�w konstruuj�cych drzewa.

library(tree)

# budowa modelu - jak wszystkich innych!
model.tree.1 <- tree(Species ~ .,data=learning.set) 

# obejrzyjmy model
model.tree.1
summary(model.tree.1)

# teraz obrazek
plot(model.tree.1,type="uniform")
title("Drzewo klasyfikacyjne")
text(model.tree.1,cex=1.2,col="blue")

# informacje o b��dnie zaklasyfikowanych obiektach (��cznie oraz osobno dla poszczeg�lnych w�z��w) 
misclass.tree(model.tree.1)
misclass.tree(model.tree.1, detail=T)

etykietki.prog <- predict(model.tree.1,test.set,type="class")

# tablica kontyngencji
(wynik.tablica <- table(etykietki.prog,etykietki.rzecz))

# b��d klasyfikacji
(n.test - sum(diag(wynik.tablica))) / n.test

# mincut  - minimalna, dopuszczalna liczba obiekt�w w jednym z w�z��w potomnych
# minsize - minimalna liczba obiekt�w w w�le, dla kt�rej jeszcze wykonujemy podzia�
# mindev  - minmalna warto�� rozrzutu (ang. "deviance") w w�le, dla ktorego jeszcze wykonujemy podzia� 
# split   - kryterium podzia�u, do wyboru mamy: "deviance" (odchylenie) lub "gini" (indeks Giniego)


##############################################
# obszary decyzyjne
# Dla drzew �atwo zobaczy� obszary decyzyjne. W tym celu musimy jednak mie� drzewo zbudowane w oparciu o jedn�
# lub dwie zmienne.

model.tree.2 <- tree(Species ~ Petal.Length + Sepal.Length,data=iris) 

par(pty = "s")
plot(iris$Petal.Length, iris$Sepal.Length, type="n", xlab="petal length", ylab="sepal length")
text(iris$Petal.Length, iris$Sepal.Length, c("s", "c", "v")[iris$Species])
partition.tree(model.tree.2,col="orange",cex=2,add=T)

##############################################     
# automatyczne przycinanie drzew
# Do tego celu s�u�y funkcja "prune.tree". Zach�camy do poznania jej argument�w, a teraz przyjrzymy si� najprostszemu
# przyk�adowi.

# budujemy skomplikowane drzewo
model.tree.3 <- tree(Species ~ Sepal.Length + Sepal.Width,data=iris)

# obcinamy
model.tree.4 <- prune.tree(model.tree.3,method="misclass",best=3)

par(mfrow=c(2,1))
plot(model.tree.3)
text(model.tree.3)
title("Oryginalne drzewo")
plot(model.tree.4)
text(model.tree.4)
title("Przyciete drzewo")

par(mfrow=c(1,1))

##############################################
# interaktywne przycinanie drzew

# przytniemy drzewo "model.tree.3" z poprzedniego przyk�adu
model.tree.3

# rysujemy i przycinamy
plot(model.tree.3,pch=1,cex=1.2)
text(model.tree.3,cex=1.2)
model.tree.3.przyciete <- snip.tree(model.tree.3)

# Uwaga: Klikamy dwukrotnie aby zaznaczy� w�z�y, kt�re chcemy odci��. Ko�czymy prac� w trybie interaktywnym
# klikaj�c prawy klawisz myszki i wybieraj�c "stop".

# zobaczmy, co wysz�o
model.tree.3.przyciete

# nowe okno graficzne
windows()
dev.set(which=dev.cur())

plot(model.tree.3.przyciete,pch=1,cex=1.2)
text(model.tree.3.przyciete,cex=1.2)


##############################################
# inne sposoby wizualizacji drzew klasyfikacyjnych

# skorzystamy z biblioteki rpart
library(rpart)

model.rpart <- rpart(Species~., data=iris, method="class")

# bardzo prosta prezentacja
plot(model.rpart, uniform=T, branch=0, margin=0.1)
text(model.rpart, digits=3, use.n=T, pretty=0)

# bardziej zaawansowana
par(xpd=T)
plot(model.rpart, uniform=T, branch=0, margin=0.08, compress=T, nspace=.8)
text(model.rpart, splits=T, all=T, pretty=0, use.n=T, fancy=T, fwidth=0.4, fheight=0.7, cex=0.8)

