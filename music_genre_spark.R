


count(mg)
X <- select(mg,chroma_stft_mean:mfcc20_var)
y <- select(mg,label) 
ggplot(data = mg, aes(x=label,y=tempo,fill = label)) + 
  geom_boxplot()
colnames(X)
select(X,grep(pattern = "mean",colnames(X),value = TRUE)) %>% 
  ml_corr(.,method = "pearson") %>% 
  ggcorrplot(.) +
  ggtitle("correlation matrix for mean varuables")

Kmean_model<- mg %>% 
  select(-label) %>% 
  select(-filename) %>% 
  select(-length) %>% 
  ml_bisecting_kmeans(k=10,label ~.)

mg_pca <- mg %>% 
  select(-label) %>% 
  select(-filename) %>% 
  select(-length) %>% 
  ml_pca(
    k=2
  )
collect(Kmean_model$centers)
ggplot(data = mg,aes(x=PC1,y = PC2)) +
  geom_point()



print(Kmean_model)
print(Kmean_model$summary)
Kmean_model$model
