library(readxl)
library(dplyr)
library(tidyr)
library(reshape2)
library(ggplot2)

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

# 성별&나이 결측치 제거하기(성별 F, M, 나이 0 이상만 추출)

nomiss_products <- filter_products %>%
  filter(!is.na(고객성별) & !is.na(고객나이)) %>%
  filter((고객성별 %in% c("F", "M")), 고객나이 > 0)

# 1-1. 색조 화장품 데이터 정리하기
cosmetics <- filter(nomiss_products, 카테고리명 == "메이크업 용품")

cosmetics

# 1-2. 기초 화장품 데이터 정리하기
skincare <- filter(nomiss_products, 카테고리명 == "스킨케어")

skincare

# 월별로 데이터 합계 정리하기 (summarise함수 또는 dcast 함수를 이용)
# 2-1. summarise 함수 이용
# 색조 화장품
summarise_cosmetics <- cosmetics %>%
  group_by(구매연월, 고객성별, 고객나이) %>%
  summarise(금액합계 = sum(구매금액))

summarise_cosmetics

library(ggplot2)

ggplot(summarise_cosmetics) +
  geom_line(mapping = aes(x = "구매연월", y = "금액합계"))


library(forcats)

x1 <- c(201901, 201902, 201903, 201904, 201905, 201906, 201907, 201908, 201909, 201910, 201911,  201912, 202001, 202002, 202003, 202004, 202005, 202006)

sort(x1)

month_levels <- c(201901, 201902, 201903, 201904, 201905, 201906, 201907, 201908, 201909, 201910, 201911,  201912, 202001, 202002, 202003, 202004, 202005, 202006)

y1 <- factor(x1, levels = month_levels)
y1



# 기초 화장품
summarise_skincare <- skincare %>%
  group_by(구매연월, 고객성별, 고객나이) %>%
  summarise(금액합계 = sum(구매금액))

summarise_skincare

# 2-2. dcast 함수 이용
# 색조 화장품
pivot_cosmetics <- dcast(cosmetics, 구매연월 ~ 고객성별 + 고객나이, value.var = "구매금액", sum)

pivot_cosmetics

# 기초 화장품
pivot_skincare <- dcast(skincare, 구매연월 ~ 고객성별 + 고객나이, value.var = "구매금액", sum, margins = T)

pivot_skincare

 
# 3-1. 색조 화장품 시각화(단위: 백만)


# 3-2.skincare 시각화(단위: 백만)

