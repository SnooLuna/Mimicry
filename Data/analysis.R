library(dplyr)
library(tidyverse)
library(reshape2)
library(ggplot2)

#####################################################

data <- read_table("//wsl.localhost/Ubuntu-24.04/home/elian/things/snake-read/out.txt", col_names = FALSE, skip = 6)

colnames(data)[1] <- "tick"
colnames(data)[2] <- "type"

mimic_data <- filter(data, type == 0)
model_data <- filter(data, type == 1)
predator_data <- filter(data, type == 2)
mean_mimic <- filter(data, type == 3)
mean_model <- filter(data, type == 4)
mean_predator <- filter(data, type == 5)

n_mimics <- 200
n_models <- 300
n_pred <- 150
n_ticks <- 200000

mimic_data <- data.frame(t(data.frame(mimic_data)))
model_data <- data.frame(t(data.frame(model_data)))
predator_data <- data.frame(t(data.frame(predator_data)))



#####################################################

# Find frequency data

mimic_data <- slice(round(mimic_data), 3:(n_mimics + 2))
model_data <- slice(round(model_data), 3:(n_models + 2))
predator_data <- slice(round(predator_data), 3:(n_pred + 2))


count_mimic <- sapply(1:ncol(mimic_data), function(col) {
  tabulate(factor(mimic_data[, col], levels = -100:100), nbins = 201) * 100 / n_mimics })

count_model <- sapply(1:ncol(model_data), function(col) {
  tabulate(factor(model_data[, col], levels = -100:100), nbins = 201) * 100 / n_models })

count_pred <- sapply(1:ncol(predator_data), function(col) {
  tabulate(factor(predator_data[, col], levels = 0:100), nbins = 101) * 100 / n_pred })

#######################################################

# Using Base R

heatmap(count_mimic, Colv = NA, Rowv = NA, main = "Visibility of mimics over time.", xlab = "Time (tick)", ylab = "Visibility", col = cm.colors(300), cexRow = 0.7, cexCol = 0.7)

heatmap(count_model, Colv = NA, Rowv = NA, main = "Visibility of models over time.", xlab = "Time (tick)", ylab = "Visibility", col = cm.colors(300), cexRow = 0.7, cexCol = 0.7)

heatmap(count_predator, Colv = NA, Rowv = NA, main = "Preffered preying color of predators over time.", xlab = "Time (tick)", ylab = "Visibility", col = cm.colors(150), cexRow = 0.7, cexCol = 0.7)

#######################################################

# Using ggplot

colnames(count_mimic) <- 0:n_ticks
rownames(count_mimic) <- 0:100
count_mimic <- melt(count_mimic)
colnames(count_mimic) <- c("y", "x", "value")

colnames(count_model) <- 0:n_ticks
rownames(count_model) <- 0:100
count_model <- melt(count_model)
colnames(count_model) <- c("y", "x", "value")

colnames(count_pred) <- 0:n_ticks
rownames(count_pred) <- 0:100
count_pred <- melt(count_pred)
colnames(count_pred) <- c("y", "x", "value")


colour_breaks <- c(0, 0.03, 0.08, 0.25, 1) #models and mimics
colour_breaks <- c(0, 0.01, 0.03, 0.1, 1)  #predators
colours <- c("white", "darkslategray1", "darkslategray3", "darkslategray4", "darkslategray")
colours_mimic <- c("white", "seagreen1", "seagreen3", "seagreen4", "#12694C")
colours_models <- c("white", "indianred1", "#E93A32", "red3", "firebrick4")
colours_preds <- c("white", "#c9d9EE", "#A0B0D0", "#8696B6", "#5B6B8B")

# mimic heatmap
ggplot(count_mimic, aes(x, y, fill = value)) + geom_tile() + 
  scale_fill_gradientn(colours = colours_mimic, values = colour_breaks) + coord_cartesian(expand = F) + labs(title="Visibility of mimics over time") + xlab("Time (ticks)") + ylab("Visibility") + guides(fill = guide_colourbar(title = "", barwidth = 15, barheight = 0.5, label.position = "bottom")) + theme(legend.position="bottom", plot.margin = margin(0.3,0.8,0.3,0.3, "cm"))

# model heatmap
ggplot(count_model, aes(x, y, fill = value)) + geom_tile() + 
  scale_fill_gradientn(colours = colours_models, values = colour_breaks) + coord_cartesian(expand = F) + labs(title="Visibility of models over time") + xlab("Time (ticks)") + ylab("Visibility") + guides(fill = guide_colourbar(title = "", barwidth = 15, barheight = 0.5, label.position = "bottom")) + theme(legend.position="bottom", plot.margin = margin(0.3,0.8,0.3,0.3, "cm"))

# predator heatmap
ggplot(count_pred, aes(x, y, fill = value)) + geom_tile() + 
  scale_fill_gradientn(colours = colours_preds, values = colour_breaks) + coord_cartesian(expand = F) + labs(title="Preferred prey of predators over time") + xlab("Time (ticks)") + ylab("Visibility") + guides(fill = guide_colourbar(title = "", barwidth = 15, barheight = 0.5)) + theme(legend.position="bottom", plot.margin = margin(0.3,0.8,0.3,0.3, "cm"))


# mimic heatmap + predator line
ggplot() + geom_tile(data = count_mimic, aes(x, y, fill = value)) +
  scale_fill_gradientn(colours = colours_mimic, values = colour_breaks) + coord_cartesian(expand = F, ylim = c(-100,100)) + labs(title="Visibility of mimics over time and\npredator preying colour") + xlab("Time (ticks)") + ylab("Visibility") + guides(fill = guide_colourbar(title = "", label.position = "bottom", barwidth = 12, barheight = 0.5)) + theme_minimal() + theme(legend.position="bottom", plot.margin = margin(0.3,0.8,0.3,0.3, "cm")) + geom_line(data = mean_predator, aes(x = tick, y = X3, colour = factor(type)), linewidth = 1.1) + scale_colour_manual(labels = c("5" = "Predators"), values = c("azure3"), name = "") + geom_ribbon(data = mean_predator, aes(x = tick, ymin = X3 - 30, ymax = X3 + 30), color = "azure2", fill = "azure4", alpha = 0.02)
# maybe use ribbon or 2 lines to just mark the outlines of the ribbon??

# mimic and predator mean lines
ggplot() + geom_line(data = mean_mimic, aes(x = tick, y = X3, colour = factor(type))) + geom_line(data = mean_predator, aes(x = tick, y = X3, colour = factor(type))) + theme_minimal() + theme(legend.position="bottom") + labs(title = "Means of mimics and predators") + xlab("Time (tick)") + ylab("Visibility") + guides(colour = "legend") + scale_colour_manual(labels = c("3" = "Mean Visibility Mimics", "5" = "Mean Preferred Prey Predators"), values = c("darkslategray3", "sienna4"), name = "")

# mimic, model and predator mean lines
ggplot() + geom_line(data = mean_mimic, aes(x = tick, y = X3, colour = factor(type)), linewidth = 1.1) + geom_line(data = mean_model, aes(x = tick, y = X3, colour = factor(type)), linewidth = 1.1) + geom_line(data = mean_predator, aes(x = tick, y = X3, colour = factor(type)), linewidth = 1.1) + theme_minimal() + theme(legend.position="bottom", legend.margin = margin(-10,0,0,0)) + labs(title = "Means of the inheritable traits\nof mimics, models and predators over time") + xlab("Time (ticks)") + ylab("Visibility") + guides(colour = "legend") + scale_colour_manual(labels = c("3" = "Mimics", "4" = "Models", "5" = "Predators"), values = c("seagreen3", "#D21A3E", "azure3"), name = "") + coord_cartesian(ylim = c(0,100))











