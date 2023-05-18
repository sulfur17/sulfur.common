﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЧерезСколькоМинутВыгнать = 3;
	НаСколькоМинутЗапретитьВход = 5;
	КодРазрешения = "Отмена";
	ПараметрыДляРазрешения = СтрШаблон("/CРазрешитьРаботуПользователей /UC%1", КодРазрешения);
	
	ЗаполнитьСписокПользователей();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ЧерезСколькоМинутВыгнатьПриИзменении(Элемент)
	ВернутьВРамки(ЧерезСколькоМинутВыгнать, 1, 5);
КонецПроцедуры

&НаКлиенте
Процедура НаСколькоМинутЗапретитьВходПриИзменении(Элемент)
	ВернутьВРамки(НаСколькоМинутЗапретитьВход, 1, 15);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьСписокПользователей(Команда)
	ЗаполнитьСписокПользователей();
КонецПроцедуры

&НаКлиенте
Процедура Выгнать(Команда)
	ВыгнатьНаСервере();
	ПоказатьОповещениеПользователя("Установлена блокировка сеансов");
КонецПроцедуры

&НаКлиенте
Процедура Отменить(Команда)
	ОтменитьНаСервере();
	ПоказатьОповещениеПользователя("Блокировка сеансов отменена");
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВыгнатьНаСервере()
	
	Блокировка = Новый БлокировкаСеансов;
	Блокировка.Установлена = Истина;
	Блокировка.Начало = РаботаСДатамиКлиентСервер.ДобавитьМинуту(ТекущаяДатаСеанса(), ЧерезСколькоМинутВыгнать);
	Блокировка.Конец = РаботаСДатамиКлиентСервер.ДобавитьМинуту(Блокировка.Начало, НаСколькоМинутЗапретитьВход);
	Блокировка.КодРазрешения = КодРазрешения;
	Блокировка.Сообщение = СтрШаблон("Вход в базу запрещен до %1 пользователем %2
		|Для преждевременной отмены блокировки зайдите с параметрами
		|""%3""", 
		Формат(Блокировка.Конец, "ДФ=HH:mm"),
		Пользователи.ТекущийПользователь(),
		ПараметрыДляРазрешения);
	
	УстановитьБлокировкуСеансов(Блокировка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВернутьВРамки(Значение, От, До)
	Если Значение < От Тогда
		Значение = От;
	КонецЕсли;
	Если Значение > До Тогда
		Значение = До;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокПользователей()
	
	СписокПользователей.Очистить();
	
	НомерСеансаИнформационнойБазы = НомерСеансаИнформационнойБазы();
	
	СеансыИнформационнойБазы = ПолучитьСеансыИнформационнойБазы();
	КоличествоАктивныхПользователей = СеансыИнформационнойБазы.Количество();
	
	Для Каждого СеансИБ Из СеансыИнформационнойБазы Цикл
		
		СтрПользователя = СписокПользователей.Добавить();
		
		СтрПользователя.Приложение   = ПредставлениеПриложения(СеансИБ.ИмяПриложения);
		СтрПользователя.НачалоРаботы = СеансИБ.НачалоСеанса;
		СтрПользователя.Компьютер    = СеансИБ.ИмяКомпьютера;
		СтрПользователя.Сеанс        = СеансИБ.НомерСеанса;
		СтрПользователя.Соединение   = СеансИБ.НомерСоединения;
		
		Если ТипЗнч(СеансИБ.Пользователь) = Тип("ПользовательИнформационнойБазы")
		   И ЗначениеЗаполнено(СеансИБ.Пользователь.Имя) Тогда
			
			СтрПользователя.Пользователь        = СеансИБ.Пользователь.Имя;
			СтрПользователя.ИмяПользователя     = СеансИБ.Пользователь.Имя;
			
		ИначеЕсли ОбщегоНазначения.РазделениеВключено()
		        И Не ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
			
			СтрПользователя.Пользователь       = Пользователи.ПолноеИмяНеуказанногоПользователя();
			СтрПользователя.ИмяПользователя    = "";
		Иначе
			СвойстваНеУказанного = ПользователиСлужебный.СвойстваНеуказанногоПользователя();
			СтрПользователя.Пользователь       = СвойстваНеУказанного.ПолноеИмя;
			СтрПользователя.ИмяПользователя    = "";
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОтменитьНаСервере()
	
	Блокировка = Новый БлокировкаСеансов;
	Блокировка.Установлена = Ложь;
	УстановитьБлокировкуСеансов(Блокировка);
	
КонецПроцедуры

#КонецОбласти
