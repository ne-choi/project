library(readxl)
library(dplyr)
library(tidyr)
library(reshape2)

# 피벗테이블 만들기_데이터 전처리
# Mcorporation 64개 데이터 합치기

files <- list.files(path = "sample/Mcorporation/category_data/", pattern = "*.xlsx", full.names = T)

products <- sapply(files, read_excel, simplify = FALSE) %>% 
  bind_rows(.id = "id") 

glimpse(products)

# 전체 필터 넣기

filter_products <- group_by(products, 카테고리명, 구매날짜, 고객성별, 고객나이, 구매금액, 구매수) %>%
  separate(구매날짜, into = c("구매연월", "삭제(일자)"), sep = 6) %>%
  select(카테고리명, 구매연월, 고객성별, 고객나이, 구매금액, 구매수)

head(filter_products, 2)

# 성별&나이 결측치 제거하기(전체 제거할지 살릴지 정하기)
nomiss_products <- filter_products %>%
  filter(!is.na(고객성별) & !is.na(고객나이))

head(nomiss_products, 2)

# 1. 색조 화장품 피벗테이블 만들기
cosmetics <- filter(nomiss_products, 카테고리명 == "메이크업 용품")

pivot_cosmetics <- dcast(cosmetics, 구매연월 ~ 고객성별 + 고객나이, value.var = "구매금액", sum, margins = T)

pivot_cosmetics

# 2. skincare 피벗테이블 만들기
skincare <- filter(nomiss_products, 카테고리명 == "스킨케어")

pivot_skincare <- dcast(skincare, 구매연월 ~ 고객성별 + 고객나이, value.var = "구매금액", sum, margins = T)

pivot_skincare

# 시계열 그래프 그리기

library(ggplot2)

graph_cosmetics <- ggplot(cosmetics, aes(x = 구매연월, y = 구매금액)) +
  geom_line()

graph_cosmetics
