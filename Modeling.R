# model creation
m1 <- glm(present ~ layer.1 + layer.2 + tree_cover_loss, data=sdm_data)
class(m1)
summary(m1)

# 2050 predictors read in
mean_rainfall2050 <- read_env('./rainfall_2050')
mean_temperature2050 <- read_env('./temperature_2050')
mean_rainfall2050 <- projectRaster(from = mean_rainfall2050, to = mean_rainfall)
mean_temperature2050 <- projectRaster(from = mean_temperature2050, to = mean_temperature)
save(mean_rainfall2050, file = './rasters/mean_rainfall2050.Rdata')
save(mean_temperature2050, file = './rasters/mean_temperature2050.Rdata')

# worst case scenario read in
mean_rainfall2050_bad <- read_env('./rainfall_2050_bad')
mean_teperature2050_bad <- read_env('./temperture_2050_bad')
mean_rainfall2050_bad <- projectRaster(mean_rainfall2050_bad, to = mean_rainfall)
mean_teperature2050_bad <- projectRaster(mean_teperature2050_bad, to = mean_temperature)
save(mean_rainfall2050_bad, file = './rasters/mean_rainfall2050_bad.Rdata')
save(mean_teperature2050_bad, file = './rasters/mean_temperature2050_bad.Rdata')

# map suitability present
prediction <- predict(predictors, m1)
plot(prediction)
ge1 <- evaluate(presences, absences, m1)
tr1 <- threshold(ge1, 'spec_sens')
plot(prediction > tr1)
plot(world, add = T)

# for 2050 rcp 26
m2 <- glm(present ~ layer.1 + layer.2 + tree_cover_loss, data = sdm_data)
predictors2050 <- stack(mean_rainfall2050, mean_temperature2050, tree_loss)
prediction2050 <- predict(predictors2050, m2)
plot(prediction2050)
ge2 <- evaluate(presences, absences, m2)
tr2 <- threshold(ge2, 'spec_sens')
plot(prediction2050 > tr2)
plot(world, add = T)

# for 2050 rcp 85
predictors2050_bad <- stack(mean_rainfall2050_bad, mean_teperature2050_bad, tree_loss)
prediction2050_bad <- predict(predictors2050_bad, m2)
ge3 <- evaluate(presences, absences, m2)
tr3 <- threshold(ge3, 'spec_sens')
plot(prediction2050_bad > tr3)
plot(world, add = T)
