
# 20201014 수정 내용
# 시각화 기준 설정:  연월, 성별 (나이대 x), y축 단위: 억 원
# 필요 작업: geom_line 추가하면 범례에만 선이 보이고 그래프에 선이 연결되지 않는 문제 해결
---
  
library(readxl)
library(dplyr)
library(tidyr)
library(reshape2)
library(ggplot2)

# 1. 데이터 전처리
# 1) Mcorporation 64개 데이터 합치기

# 파일 합치기
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

# 2) 필요한 데이터 정리하기
# 색조 화장품
cosmetics <- filter(nomiss_products, 카테고리명 == "메이크업 용품")

cosmetics

# 월별 데이터 합계_색조
summarise_cosmetics <- cosmetics %>%
  group_by(구매연월, 고객성별) %>%
  summarise(금액합계 = sum(구매금액))

summarise_cosmetics


# 기초 화장품
skincare <- filter(nomiss_products, 카테고리명 == "스킨케어")

skincare

# 월별 데이터 합계_기초
summarise_skincare <- skincare %>%
  group_by(구매연월, 고객성별) %>%
  summarise(금액합계 = sum(구매금액))

summarise_skincare


# 3) 시각화하기
# '단위: 억' 적용
label_ko_num = function(num){
  ko_num = function(x){
    new_num = x %/% 100000000
    return(paste(new_num, '억', sep = ''))
  }
  return(sapply(num, ko_num))
}

#색조 화장품
library(ggplot2)

graph_cosmetics <- ggplot(summarise_cosmetics, aes(x = 구매연월, y = 금액합계, color = 고객성별)) +
  geom_point() +
  scale_y_continuous(labels = label_ko_num) +
theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  theme(legend.position = "bottom")

graph_cosmetics

#기초 화장품
graph_skincare <- ggplot(summarise_skincare, aes(x = 구매연월, y = 금액합계, color = 고객성별)) +
  geom_point() +
  scale_y_continuous(labels = label_ko_num) +
theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
theme(legend.position = "bottom")

graph_skincare
