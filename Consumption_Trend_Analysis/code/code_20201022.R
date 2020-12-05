library(readxl)
library(dplyr)
library(tidyr)
library(reshape2)
library(ggplot2)
library(lubridate)

# 1. 데이터 전처리
# 1) Mcorporation 64개 데이터 합치기

# 파일 합치기
files <- list.files(path = "sample/Mcorporation/상품 카테고리 데이터_KDX 시각화 경진대회 Only/use", pattern = "*.xlsx", full.names = T)

products <- sapply(files, read_excel, simplify = FALSE) %>% 
  bind_rows(.id = "id") 

glimpse(products)
str(products)

# 성별&나이 결측치 제거하기(성별 F, M, 나이 0 이상만 추출)
nomiss_products <- products %>%
  filter(!is.na(고객성별) & !is.na(고객나이)) %>%
  filter((고객성별 %in% c("F", "M")), 고객나이 > 0) %>%
  select(카테고리명, 구매날짜, 고객성별, 고객나이, OS유형, 구매금액, 구매수)

products

frame_makeup <- nomiss_products %>%
  filter(카테고리명 == "메이크업 용품")

frame_makeup

frame_skincare <- nomiss_products %>%
  filter(카테고리명 == "스킨케어")
  
frame_skincare
  
# 2) 필요한 데이터 정리하기

# 비교값 만들기
compare_products <- nomiss_products %>%
  group_by(카테고리명, 구매날짜, 고객성별) %>%
  summarise(금액합계 = sum(구매금액))

compare_products


# 억 원 단위 생성
label_ko_num = function(num){
  ko_num = function(x){
    new_num = x %/% 100000000
    return(paste(new_num, '억', sep = ''))
  }
  return(sapply(num, ko_num))
}


# 문자형 날짜 데이터로 전환
library(lubridate)

final_products <- compare_products %>%
  mutate(구매일 = ymd(구매날짜))

# 색조화장품

final_products

cosmetics <- final_products %>%
  filter(카테고리명 == "메이크업 용품")

str(cosmetics)


library(extrafont)
font_import(pattern = "NanumSquare")
y

loadfonts(device = "win")

theme_update(text = element_text(family = "NanumSquare_ac Bold"))

graph_cosmetics <- ggplot(cosmetics, aes(x = 구매일, y = 금액합계, color = 고객성별)) +
  geom_smooth() + geom_point(size = 0.1) +
  scale_y_continuous(labels = label_ko_num, breaks = seq(0, 2000000000, by = 250000000)) +
  scale_x_date(date_breaks="3 month", minor_breaks=NULL, date_labels = "%Y.%m") +
  theme(
    axis.text.x = element_text(size = 8,family= "NanumSquare_ac", hjust = 1),
    axis.text.y = element_text(size = 8,family = "NanumSquare_ac"),
    legend.position = "bottom",
    axis.title.x = element_text(size = 12, family = "NanumSquare_ac"),
    axis.title.y = element_text(size = 12, family = "NanumSquare_ac"),
  )

graph_cosmetics

# 기초화장품
skincare <- final_products %>%
  filter(카테고리명 == "스킨케어")

str(skincare)


library(extrafont)
font_import(pattern = "NanumSquare")
y

loadfonts(device = "win")

theme_update(text = element_text(family = "NanumSquare_ac Bold"))

graph_skincare <- ggplot(skincare, aes(x = 구매일, y = 금액합계, color = 고객성별)) +
  geom_smooth() + geom_point(size = 0.1) +
  scale_y_continuous(labels = label_ko_num, breaks = seq(0, 600000000, by = 100000000)) +
  scale_x_date(date_breaks="3 month", minor_breaks=NULL, date_labels = "%Y.%m") +
  theme(
    axis.text.x = element_text(size = 8, family= "NanumSquare_ac", hjust = 1),
    axis.text.y = element_text(size = 8, family = "NanumSquare_ac"),
    legend.position = "bottom",
    axis.title.x = element_text(size = 12, family = "NanumSquare_ac"),
    axis.title.y = element_text(size = 12, family = "NanumSquare_ac"),
  ) + 
  theme_light()

graph_skincare



# 카테고리 합쳐 조회

final_products1 <- final_products

final_products1

levels(final_products1$카테고리명)


graph_products <- ggplot(final_products, aes(x = 구매일, y = 금액합계, color = 고객성별)) +
  geom_smooth() + geom_point(size = 0.1) +
  scale_y_continuous(labels = label_ko_num) +
  scale_x_date(date_breaks="3 month", minor_breaks=NULL, date_labels = "%Y.%m") +
  labs(title = "카테고리별 매출액 조회") +
  theme(
    plot.title = element_text(size = 16, family = "NanumSquare_ac Bold", hjust = 0.5),
    axis.text.x = element_text(angle = 30, size = 8, family= "NanumSquare_ac", hjust = 1),
    axis.text.y = element_text(size = 8,family = "NanumSquare_ac"),
    legend.position = "bottom",
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 10, family = "NanumSquare_ac"),
  ) +
  facet_wrap(~ 카테고리명, ncol = 2, scales = "free", labeller = labeller(카테고리명 = new_labels))

graph_products


# 라벨 변경
new_labels <- c("메이크업 용품" = "색조 화장품", "스킨케어" = "기초화장품")

library(labeling)


#####-----
# 카드 데이터 그래프화

# 신한카드
shinhancard <- read_xlsx("sample/Shinhancard.xlsx")
head(shinhancard)

shinhancard <- shinhancard %>%
  select(-c(6:8))

head(shinhancard)

filter_sh_beauty <- shinhancard %>%
  select(업종, 일별, 성별, 연령대별, '카드이용건수(천건)') %>%
  filter(업종 == "M018_화장품")

head(filter_sh_beauty)

#-- 신한카드 그래프
# 성별&나이 결측치 제거하기(성별 F, M, 나이 0 이상만 추출)
nomiss_sh_beauty <- filter_sh_beauty %>%
  filter(!is.na(성별) & !is.na(연령대별)) %>%
  filter((성별 %in% c("F", "M")), 연령대별 > 0)

nomiss_sh_beauty

# 구매수 합계
sum_sh_beauty <- nomiss_sh_beauty %>%
  group_by(일별, 성별) %>%
  summarise(구매횟수 = sum(`카드이용건수(천건)`))

sum_sh_beauty

# 시계열 데이터로 변환
final_sh_beauty <- sum_sh_beauty %>%
  mutate(구매일자 = ymd(일별))

final_sh_beauty

# 그래프 그리기
graph_sh_beauty <- ggplot(final_sh_beauty, aes(x = 구매일자, y = 구매횟수, color = 성별)) +
  geom_smooth() + geom_point(size = 0.1) +
  scale_x_date(date_breaks="3 month", minor_breaks=NULL, date_labels = "%Y.%m") +
  scale_y_continuous(breaks = seq(0, 200, by = 20)) +
  theme(
    axis.text.x = element_text(size = 8, family= "NanumSquare_ac", hjust = 1),
    axis.text.y = element_text(size = 8, family = "NanumSquare_ac"),
    legend.position = "bottom",
    axis.title.x = element_text(size = 12, family = "NanumSquare_ac"),
    axis.title.y = element_text(size = 12, family = "NanumSquare_ac"),
  )
   
graph_sh_beauty

# bbc style

if(!require(pacman))install.packages("pacman")

pacman::p_load('dplyr', 'tidyr', 'gapminder',
               'ggplot2',  'ggalt',
               'forcats', 'R.utils', 'png', 
               'grid', 'ggpubr', 'scales',
               'bbplot')

install.packages('devtools')
devtools::install_github('bbc/bbplot')

graph_sh_beauty <- ggplot(final_sh_beauty, aes(x = 구매일자, y = 구매횟수, color = 성별)) +
  geom_smooth() + geom_point(size = 0.1) +
  scale_x_date(date_breaks="3 month", minor_breaks=NULL, date_labels = "%Y.%m") +
  scale_y_continuous(breaks = seq(0, 200, by = 20)) +
  theme(
    axis.text.x = element_text(size = 8, family= "NanumSquare_ac", hjust = 1),
    axis.text.y = element_text(size = 8, family = "NanumSquare_ac"),
    legend.position = "bottom",
    axis.title.x = element_text(size = 12, family = "NanumSquare_ac"),
    axis.title.y = element_text(size = 12, family = "NanumSquare_ac"),
  ) +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  scale_colour_manual(values = c("#EB3232", "#FAAB18")) +
  bbc_style()
   
graph_sh_beauty
